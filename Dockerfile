FROM python:3.8.10

RUN apt-get update && apt-get install -y coffeescript

COPY . /snaut 

WORKDIR /snaut

RUN /usr/bin/coffee -c -o ./snaut/static/js/snaut ./snaut/coffee

RUN python3 -m pip install wheel gunicorn
RUN python3 -m pip install -r /snaut/requirements.txt


ENTRYPOINT ["gunicorn", "--bind",  "0.0.0.0:8090", "snaut.wsgi:app"]
