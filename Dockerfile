FROM python:3.7.3


COPY . /snaut 
RUN python3 -m pip install wheel
RUN python3 -m pip install gunicorn
RUN python3 -m pip install -r /snaut/requirements.txt

WORKDIR /snaut
ENTRYPOINT ["gunicorn", "--bind",  "0.0.0.0:8090", "snaut.wsgi:app"]
