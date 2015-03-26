#ifndef __CRYPTO_OPENSSL_H__
#define __CRYPTO_OPENSSL_H__

/* Convert a (PEM) certificate to a descriptive string. Used for debugging only */
char *openssl_cert_to_string (const char *pem);

/* Convert a (PEM) CRL to a descriptive string. Used for debugging only */
char *openssl_crl_to_string (const char *pem);

/*
 * Return a list of string (char *) of the serial number of revoked certs. The list
 * terminated by a NULL entry. The caller MUST free the memory. This includes
 * the individual char * and the char **.
 */
char **openssl_crl_get_revoked (const char *crl_pem, const char *cert_pem, const char **reason);

#endif /* __CRYPTO_OPENSSL_H_ */
