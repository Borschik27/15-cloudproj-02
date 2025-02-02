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
