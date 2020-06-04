FROM python:3.8.0

WORKDIR /home

RUN apt-get update

COPY requirements.txt /home/requirements.txt

RUN pip install -r requirements.txt

RUN git clone https://github.com/arteria/django-background-tasks.git \
    && cd django-background-tasks && pip install -r requirements.txt && python setup.py

VOLUME ["/home"]

COPY . .

RUN chmod +x /home/entrypoint.sh

EXPOSE 8080
EXPOSE 80

ENTRYPOINT [ "/home/entrypoint.sh" ]