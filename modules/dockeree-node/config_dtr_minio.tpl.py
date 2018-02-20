#!/usr/bin/env python
# Configure the DTR with the Minio (S3-compatible) storage backend

import requests

base_url = 'https://127.0.0.1'
login_url = base_url + '/login'
logout_url = base_url + '/logout'
registry_url = base_url + '/api/v0/admin/settings/registry/simple'
credentials = {
    'username': '${ucp_admin_username}',
    'password': '${ucp_admin_password}'
}

r = requests.post(login_url, credentials, verify=False)
if r.status_code != 200:
    print("Error: Something went wrong logging into DTR!")
    exit()

storage_config = {
    'delete': {'enabled': True},
    'maintenance': {'readonly': {'enabled': False}},
    's3': {'accesskey': '${minio_access_key}',
           'bucket': 'dtr',
           'region': 'none',
           'regionendpoint': '${minio_endpoint}',
           'secretkey': '${minio_secret_key}',
           'secure': False,
           'skipverify': False}}

jar = r.cookies
hdr = {'X-Csrf-Token': jar['csrftoken']}
r = requests.put(registry_url, json={'storage': storage_config},
                 headers=hdr, cookies=jar, verify=False)

if r.status_code != 202:
    print("Error: Uploading config gave status code: " + str(r.status_code))
    exit()

requests.get(logout_url, cookies=jar, verify=False)
print("Applied Minio storage configuration to DTR.")
