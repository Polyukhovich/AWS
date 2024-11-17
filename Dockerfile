FROM python:3

# Додаємо файл додатку у кореневу директорію контейнера
ADD app.py /

# Встановлюємо необхідні бібліотеки
RUN pip install flask
RUN pip install flask_restful

# Відкриваємо порт 8088
EXPOSE 8080

# Вказуємо команду для запуску додатку
CMD ["python", "./app.py"]
