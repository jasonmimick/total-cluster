FROM python:3.7 as base

ADD requirements.txt /requirements.txt
RUN pip install -r requirements.txt

FROM base as app

ADD . / 

FROM app as runtime

EXPOSE 5000
CMD ["python", "/main.py"]
