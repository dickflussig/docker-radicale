FROM python:3.11.0b3-alpine
RUN adduser -D radicle
USER radicle
RUN pip install --no-cache-dir --upgrade radicale
WORKDIR /app
COPY --chown=radicle:radicle /app /app
ENV PATH="/home/radicle/.local/bin:${PATH}"
ENV LOCK_FILE Collection.lock
EXPOSE 5232
CMD [ "python3", "-m", "radicale", "-C", "conf/radicale.conf"]