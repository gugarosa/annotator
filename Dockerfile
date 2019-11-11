ARG PYTHON_VERSION="3.6"
FROM python:${PYTHON_VERSION}-stretch AS builder

ARG NODE_VERSION="8.x"
RUN curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}" | bash - \
 && apt-get install --no-install-recommends -y \
      nodejs


COPY tools/install-mssql.sh /smart_noter/tools/install-mssql.sh
RUN ["chmod", "+x", "/smart_noter/tools/install-mssql.sh"]
RUN /smart_noter/tools/install-mssql.sh --dev

COPY app/server/static/package*.json /smart_noter/app/server/static/
RUN cd /smart_noter/app/server/static \
 && npm ci

COPY requirements.txt /
RUN pip install -r /requirements.txt \
 && pip wheel -r /requirements.txt -w /deps

COPY . /smart_noter

WORKDIR /smart_noter

FROM builder AS cleaner

RUN cd /smart_noter/app/server/static \
 && SOURCE_MAP=False DEBUG=False npm run build \
 && rm -rf components pages node_modules .*rc package*.json webpack.config.js

RUN cd /smart_noter \
 && python app/manage.py collectstatic --noinput

FROM python:${PYTHON_VERSION}-slim-stretch AS runtime

COPY --from=builder /smart_noter/tools/install-mssql.sh /smart_noter/tools/install-mssql.sh
RUN ["chmod", "+x", "/smart_noter/tools/install-mssql.sh"]
RUN /smart_noter/tools/install-mssql.sh

RUN useradd -ms /bin/sh smart_noter

COPY --from=builder /deps /deps
RUN pip install --no-cache-dir /deps/*.whl

COPY --from=cleaner --chown=smart_noter:smart_noter /smart_noter /smart_noter

ENV DEBUG="True"
ENV SECRET_KEY="Iamasecretkeyprodready"
ENV PORT="8000"
ENV WORKERS="2"
ENV GOOGLE_TRACKING_ID=""
ENV AZURE_APPINSIGHTS_IKEY=""
ENV ADMIN_USERNAME: "admin"
ENV ADMIN_PASSWORD: "password"
ENV ADMIN_EMAIL: "admin@example.com"

USER smart_noter
WORKDIR /smart_noter
EXPOSE ${PORT}

RUN ["chmod", "+x", "/smart_noter/tools/run.sh"]
CMD ["/smart_noter/tools/run.sh"]
