/* Copyright 2015, Nacho Cove, Inc. All rights reserved. */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#include "include/openssl/x509.h"
#include "include/openssl/bio.h"
#include "include/openssl/pem.h"
#include "crypto_openssl.h"

#define TRUE (1)
#define FALSE (0)

#define MAX_CERT_LEN (100 * 1024) /* assume no cert is larger than 100 KB */
#define MAX_CRL_LEN (100 * 1024) /* assume no CRL is larger than 100 KB */
#define MAX_DESC_BUF_SIZE (32 * 1024)
#define MAX_SN_SIZE (512)

typedef struct nc_buffer_ {
    char *buf;
    int buf_size;
    int cur_idx;
} nc_buffer_t;

nc_buffer_t *
nc_buffer_alloc (int size)
{
    nc_buffer_t *buf = (nc_buffer_t *)malloc(sizeof(nc_buffer_t));
    if (NULL == buf) {
        return NULL;
    }
    memset(buf, 0, sizeof(nc_buffer_t));
    buf->buf_size = size + 1;
    buf->buf = (char *)malloc(buf->buf_size);
    if (NULL == buf->buf) {
        free(buf);
        return NULL;
    }
    memset(buf->buf, 0, buf->buf_size);
    buf->cur_idx = 0;
    
    return buf;
}

char *
nc_buffer_free (nc_buffer_t *buf)
{
    if (NULL == buf) {
        return NULL;
    }
    char *data = buf->buf;
    memset(buf, 0, sizeof(nc_buffer_t));
    free(buf);
    
    return data;
}

int
nc_buffer_is_valid (nc_buffer_t *buf)
{
    return ((NULL != buf) &&
            (NULL != buf->buf) &&
            (0  <= buf->buf_size) &&
            (buf->cur_idx < buf->buf_size));
}

int
nc_buffer_printf (nc_buffer_t *buf, const char *fmt, ...)
{
    if (!nc_buffer_is_valid(buf)) {
        return EINVAL;
    }
    
    /* Make sure that we still have space */
    if (buf->cur_idx == buf->buf_size) {
        return ENOSPC;
    }
    
    va_list va;
    va_start(va, fmt);
    int num_chars = vsnprintf(&buf->buf[buf->cur_idx], buf->buf_size - buf->cur_idx, fmt, va);
    va_end(va);
    if ((buf->cur_idx + num_chars) > buf->buf_size) {
        buf->cur_idx = buf->buf_size;
        return E2BIG;
    } else {
        buf->cur_idx += num_chars;
    }
    return 0;
}

X509 *
openssl_PEM_to_cert (const char *pem)
{
    if (NULL == pem) {
        return NULL;
    }
    size_t len = strnlen(pem, MAX_CERT_LEN);
    if (MAX_CERT_LEN <= len) {
        return NULL;
    }
    BIO *mem = BIO_new_mem_buf((void *)pem, (int)len+1);
    X509 *cert = PEM_read_bio_X509(mem, NULL, NULL, NULL);
    BIO_free (mem);
    return cert;
}

X509_CRL *
openssl_PEM_to_CRL (const char *pem)
{
    if (NULL == pem) {
        return NULL;
    }
    size_t len = strnlen(pem, MAX_CRL_LEN);
    if (MAX_CRL_LEN <= len) {
        return NULL;
    }
    BIO *mem = BIO_new_mem_buf((void *)pem, (int)len+1);
    X509_CRL *crl = PEM_read_bio_X509_CRL(mem, NULL, NULL, NULL);
    BIO_free (mem);
    return crl;
}

char *
openssl_cert_to_string (const char *pem)
{
    nc_buffer_t *buf = nc_buffer_alloc(MAX_DESC_BUF_SIZE);
    if ((NULL == buf) || (NULL == pem)) {
        return NULL;
    }
    long len = strnlen(pem, MAX_CERT_LEN);
    if (MAX_CERT_LEN <= len) {
        nc_buffer_printf(buf, "The certificate size exceeds the maximum expected value (%ld)", MAX_CERT_LEN);
    } else {
        X509 *cert = openssl_PEM_to_cert(pem);
        if (NULL == cert) {
            nc_buffer_printf(buf, "%s", "Cannot parse certificate");
        } else {
            char tmp_buf[1024];
            long version = X509_get_version(cert) + 1;
            nc_buffer_printf(buf, "Version: %ld\n", version);
            char *subject = X509_NAME_oneline(X509_get_subject_name(cert), tmp_buf, sizeof(tmp_buf));
            nc_buffer_printf(buf, "Subject: %s\n", subject);
            char *issuer = X509_NAME_oneline(X509_get_issuer_name(cert), tmp_buf, sizeof(tmp_buf));
            nc_buffer_printf(buf, "Issuer: %s\n", issuer);
        }
    }
    return nc_buffer_free(buf);
}

char *
openssl_crl_to_string (const char *pem)
{
    nc_buffer_t *buf = nc_buffer_alloc(MAX_DESC_BUF_SIZE);
    if ((NULL == buf) || (NULL == pem)) {
        return NULL;
    }
    long len = strnlen(pem, MAX_CRL_LEN);
    if (MAX_CRL_LEN <= len) {
        nc_buffer_printf(buf, "The CRL size exceeds the maximum expected value (%d)", MAX_CRL_LEN);
    } else {
        X509_CRL *crl = openssl_PEM_to_CRL(pem);
        if (NULL == crl) {
            nc_buffer_printf(buf, "%s", "Cannot parse CRL");
        } else {
            char tmp_buf[1024];
            long version = X509_CRL_get_version(crl) + 1;
            nc_buffer_printf(buf, "Version: %ld\n", version);
            char *issuer = X509_NAME_oneline(X509_CRL_get_issuer(crl), tmp_buf, sizeof(tmp_buf));
            nc_buffer_printf(buf, "Issuer: %s\n", issuer);
            
            // Dump all revoked certs
            STACK_OF(X509_REVOKED) *revoked = X509_CRL_get_REVOKED(crl);
            if (0 >= sk_X509_REVOKED_num(revoked)) {
                nc_buffer_printf(buf, "No revoked certificate\n");
            } else {
                for (int n = 0; n < sk_X509_REVOKED_num(revoked); n++) {
                    X509_REVOKED *r = sk_X509_REVOKED_value(revoked, n);
                
                    nc_buffer_printf(buf, "\n[CRL entry %d]\n", n + 1);
                    char *serial_number = BN_bn2hex(ASN1_INTEGER_to_BN(r->serialNumber, NULL));
                    nc_buffer_printf(buf, "Serial Number: %s\n", serial_number);
                    nc_buffer_printf(buf, "Revocation Date: %s\n", ASN1_STRING_data(r->revocationDate));
                    
                    // Parse the extension
                    int num_ext = X509_REVOKED_get_ext_count(r);
                    for (int m = 0; m < num_ext; m++) {
                        nc_buffer_printf(buf, "  [CRL extension %d]\n", m + 1);
                    }
                }
            }
        }
    }
    return nc_buffer_free(buf);
}

char **
openssl_crl_get_revoked (const char *crl_pem, const char *cert_pem, const char **reason)
{
    X509 *signing_cert = NULL;
    if (NULL != cert_pem) {
        signing_cert = openssl_PEM_to_cert(cert_pem);
        if (NULL == signing_cert) {
            *reason = "Cannot parse signing cert";
            return NULL;
        }
    }
    
    X509_CRL *crl = openssl_PEM_to_CRL(crl_pem);
    if (NULL == crl) {
        *reason = "Cannot parse CRL";
        return NULL;
    }
    
    if (0 >= X509_CRL_verify(crl, X509_get_pubkey(signing_cert))) {
        *reason = "Invalid CRL";
        return NULL;
    }
    
    STACK_OF(X509_REVOKED) *revoked = X509_CRL_get_REVOKED(crl);
    int num_revoked = sk_X509_REVOKED_num(revoked);
    if (0 >= num_revoked) {
        num_revoked = 0;
    }
    
    char **sn_list = (char **)malloc((num_revoked + 1) * sizeof(char *));
    if (NULL == sn_list) {
        return NULL;
    }
    sn_list[num_revoked] = NULL; /* terminating entry */
    
    for (int n = 0; n < sk_X509_REVOKED_num(revoked); n++) {
        X509_REVOKED *r = sk_X509_REVOKED_value(revoked, n);
        char *serial_number = BN_bn2hex(ASN1_INTEGER_to_BN(r->serialNumber, NULL));
        sn_list[n] = strndup(serial_number, MAX_SN_SIZE);
    }
    *reason = "OK";
    return sn_list;
}
