# 15-cloudproj-02
## Данный проект собран на основе прошлого.
## Проект полностью доступен
### Как устроен проект:
  1. Создает публичное хранилище
  2. Загружает файл в него
  3. Ренедерит три cloud-init конфига:
     3.1. Для виртульных тестовых машин
     3.2. Для NAT-инстанса
     3.3. Для WEB-сервиса
  4. Создаются два публичных адреса:
     4.1. Для NAT-инстанса что бы узлы выходили в сеть
     4.2. Для LoadBalancer что бы можно было получить доступ через LB к WEB-кластеру
  5. Создается VPC
  6. Создается две подсети:
     6.1. Public - Для LoadBalancer и NAT-инстанс
     6.2. Private - Для WEB-кластера
  7. Создается NAT-инстанс
  8. Создается Таблица маршрутизации и Группа Безопастности
  9. Создаются группа машин LAMP кластера со своими именами и конкрентыми ip-адресам и сразу таргет группа для LB
  10. Создается LoadBalancer с созданной раннее группой

![image](https://github.com/user-attachments/assets/8574656b-a4aa-4601-9c31-91ef1e630a13)

# Задача 1
## 1
![image](https://github.com/user-attachments/assets/8bbdbf55-b9b7-44b0-af35-3e632beaa40a)

![image](https://github.com/user-attachments/assets/50dd280c-1cd7-462a-8124-3c43d2907351)

## 2
### Страница для web-сервера создается через cloud-init ссылка на скачку файла генерируется автоматически

```
#cloud-config
users:
  - name: ${uname}
    groups: ${ugroup}
    shell: ${shell}
    sudo: '${s_com}'
    plain_text_passwd: ${vm_user_password}
    lock_passwd: false
    ssh_authorized_keys:
      - ${ssh_key}

write_files:
  - path: /etc/ssh/sshd_config.d/99-cloud-init.conf
    content: |
      PasswordAuthentication yes
      PermitRootLogin yes
      ChallengeResponseAuthentication no

  - path: /var/www/html/index.html
    content: |
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome to My Web Server</title>
      </head>
      <body>
          <h1>Welcome Sypchik!</h1>
          <p>This is the default page served by the web server.</p>
          <p>Download the image here: <a href="https://storage.yandexcloud.net/${bucket_name}/main.jpg">main.jpg</a></p>
      </body>
      </html>

runcmd:
  - systemctl restart ssh
  - systemctl restart apache2
```

![408911609-0979313a-c5aa-4312-9778-7631e2a65a16](https://github.com/user-attachments/assets/70c6c854-da5c-4a7c-a73f-51688550ca79)


При клике срабатывает загрузка файла:
![408911899-61620687-228d-42af-9b40-8c8809c52f68](https://github.com/user-attachments/assets/8e7fe095-d1a9-45fa-a367-8469eee674b0)

## 4
Так же работает LB

![408912187-d9d2e0f5-4872-41b9-b99c-16aa19e6f2e4](https://github.com/user-attachments/assets/788423a0-728c-4966-a154-ba2a46237773)


Отключим пару web-серверов и проверим доступность

![image](https://github.com/user-attachments/assets/d8d9b8dd-57ed-45bc-ae22-db433a3dc97e)

Постучимся на сайт в приватном режиме
![408912890-ff59ff84-01cd-41f7-b904-56170497d005](https://github.com/user-attachments/assets/096196dd-6b4f-431b-a1ff-8795d1bb4bf0)


