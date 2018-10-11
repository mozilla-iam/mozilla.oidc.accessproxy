FROM python:3
MAINTAINER kang <kang@insecure.ws>

WORKDIR /usr/src/app
COPY app/* ./
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080
STOPSIGNAL SIGTERM
CMD [ "python", "app.py" ]
