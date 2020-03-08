# https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker
# Temporary fix until Nix builds
FROM python:3.8.1-slim-buster as base

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  APP_HOME=/usr/src/app/ \
  STATIC_DIR=/www/static \
  MEDIA_DIR=/www/media

###########
# BUILDER #
###########

# pull official base image
FROM base as builder

# set work directory
WORKDIR $APP_HOME

# install psycopg2 dependencies
RUN apt-get update \
     && apt-get install -y --no-install-recommends python3-dev libffi-dev ca-certificates build-essential \
        # Psycopg2
        libpq-dev postgresql-client postgresql-client-common \
        # Pillow
        libjpeg-dev  \
    && ln -s /usr/include/locale.h /usr/include/xlocale.h


# Poetry, pip, virtual env
COPY poetry.lock pyproject.toml ./
RUN pip install --upgrade pip
RUN python -m venv /venv
RUN /venv/bin/pip install --upgrade cython "poetry>=1.0.0"

COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --without-hashes | /venv/bin/pip install -r /dev/stdin

COPY . .
RUN  /venv/bin/poetry config virtualenvs.create false \
  && /venv/bin/poetry build \
  && /venv/bin/pip install dist/*.whl


#########
# FINAL #
#########

# pull official base image
FROM base as final

# create the app user
RUN addgroup --system --gid 6969 app && adduser --system --uid 6969 app --ingroup app

# Create directories
RUN install -d -m 0777 -o app -g app $APP_HOME \
 && install -d -m 0777 -o app -g app $STATIC_DIR \
 && install -d -m 0777 -o app -g app $MEDIA_DIR
WORKDIR $APP_HOME


# install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 libffi-dev netcat

# copy entrypoints
COPY --chown=app:app ./docker/entrypoint.sh webcat/asgi.py manage.py $APP_HOME

# Copy over virtual env
COPY --chown=app:app --from=builder /venv /venv

USER app:app
ENTRYPOINT ["./entrypoint.sh"]
