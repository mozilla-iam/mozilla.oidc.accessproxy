FROM centos:latest
MAINTAINER kang <kang@insecure.ws>

# Load package keys, add repos, install support packages, install openresty, lua-resty-openidc and credstash
RUN gpg="gpg --no-default-keyring --secret-keyring /dev/null --keyring /dev/null --no-option --keyid-format 0xlong" && \
    rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    rpm -qi gpg-pubkey-f4a80eb5 | $gpg | grep 0x24C6A8A7F4A80EB5 && \
    rpmkeys --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 && \
    rpm -qi gpg-pubkey-352c64e5 | $gpg | grep 0x6A2FAEA2352C64E5 && \
    rpmkeys --import https://openresty.org/package/pubkey.gpg && \
    rpm -qi gpg-pubkey-d5edeb74 | $gpg | grep 0x97DB7443D5EDEB74 && \
    yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo && \
    yum update -y && \
    yum install -y --setopt=tsflags=nodocs openresty-opm openresty openresty-resty&& \
    opm get zmartzone/lua-resty-openidc && \
    yum erase -y openresty-opm && \
    yum install -y --setopt=tsflags=nodocs epel-release && \
    yum install -y --setopt=tsflags=nodocs python-pip && \
    pip install credstash && \
    yum erase -y python-pip && \
    mkdir -v /usr/local/openresty/nginx/conf/ssl && \
    openssl_cnf_filename=`mktemp` && \
    printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > $openssl_cnf_filename && \
    /usr/local/openresty/openssl/bin/openssl req -x509 -out /usr/local/openresty/nginx/conf/ssl/localhost.crt \
      -keyout /usr/local/openresty/nginx/conf/ssl/localhost.key \
      -newkey rsa:2048 -nodes -sha256 -subj '/CN=localhost' -extensions EXT -config $openssl_cnf_filename

#     yum install -y --setopt=tsflags=nodocs sudo openssl-devel lua-devel yum-utils && \

ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/

# Logs and setup
USER root
RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log && \
	ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log && \
	ln -sf /usr/local/openresty/nginx/logs/access.log /var/log/access.log && \
	ln -sf /usr/local/openresty/nginx/logs/error.log /var/log/error.log
COPY etc/conf.d /usr/local/openresty/nginx/conf/conf.d/
COPY etc/nginx.conf /usr/local/openresty/nginx/conf/

# Ports and Docker stuff
EXPOSE 80
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]
