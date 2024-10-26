FROM ubuntu:jammy
LABEL org.opencontainers.image.authors="fauzi.mkom@gmail.com"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG=en_US.UTF-8

# Retrieve the target architecture to install the correct wkhtmltopdf package
ARG TARGETARCH

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils && \
    if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  ;; \
    "arm64")  WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc  ;; \
    "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Odoo
ENV ODOO_VERSION=17.0
ARG ODOO_RELEASE=20241017
ARG ODOO_SHA=e5d7e6c6d011698cb6589e2a9b717caaac69df35
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Custom hide doc,support,setting,account on user menu
RUN sed -i '/id: "documentation",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js \
    && sed -i '/id: "support",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js \
    && sed -i '/id: "settings",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js \
    && sed -i '/id: "account",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js

# GPT hanya diizinkan untuk Admin
RUN sed -i "s/callback: async () => this.openChatGPTDialog(),/callback: async() => {const uid = (Array.isArray(session.user_id) ? session.user_id[0] : session.user_id)  | session.uid;if(uid==2){this.openChatGPTDialog()}},/g" /usr/lib/python3/dist-packages/odoo/addons/web_editor/static/src/js/wysiwyg/wysiwyg.js

# Text debranding
RUN files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" "Odoo" "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/\bOdoo\b/MERP/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" "OdooBot" "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/\bOdooBot\b/Rin/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" "ChatGPT" "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/\bChatGPT\b/ProfRin/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'www.odoo.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/www.odoo.com/www.manzada.net/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'odoo.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/accounts.odoo.com/accounts.manzada.net/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'odoo@example.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/odoo@example.com/mail@example.com/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'odoobot@example.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/odoobot@example.com/mail@example.com/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Negara-Negara' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Negara-Negara/Negara/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'hari-hari' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/hari-hari/hari/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Vendor Terbai' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Vendor Terbai/Vendor Terbaik/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Vendor Terbaikk' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Vendor Terbaikk/Vendor Terbaik/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Kategori Produk Terbai' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Kategori Produk Terbai/Kategori Produk Terbaik/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Kategori-Kategori Terbaik' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Kategori-Kategori Terbaik/Kategori Produk Terbaik/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Salespeople Terbaik' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Salespeople Terbaik/Salesman Terbaik/g' \
    && files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Memerintahkan' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Memerintahkan/Ordered/g'

# Image debranding
COPY ./img/*.png /usr/lib/python3/dist-packages/odoo/addons/web/static/img/
COPY ./img/*.svg /usr/lib/python3/dist-packages/odoo/addons/web/static/img/
COPY ./img/*.ico /usr/lib/python3/dist-packages/odoo/addons/web/static/img/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC=/etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# chmod entrypoint.sh wait-for-psql.py to executable
RUN chmod +x /entrypoint.sh \
    && chmod +x /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
