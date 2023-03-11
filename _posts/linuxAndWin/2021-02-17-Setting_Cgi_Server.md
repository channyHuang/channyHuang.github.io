---
layout: default
title: Setting_Cgi_Server
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2021-02-17 10:02:48

//Author: channy

# Setting_Cgi_Server

1. install apapche2

```
sudo apt-get install apache2
```

2. change cgi path in file server-cgi-bin.conf

default path: /etc/apache2/conf-available

change path to /var/www/cgi-bin

```
<IfModule mod_alias.c>
        <IfModule mod_cgi.c>
                Define ENABLE_USR_LIB_CGI_BIN
        </IfModule>

        <IfModule mod_cgid.c>
                Define ENABLE_USR_LIB_CGI_BIN
        </IfModule>

        <IfDefine ENABLE_USR_LIB_CGI_BIN>
                ScriptAlias /cgi-bin/ /var/www/cgi-bin/
                <Directory "/var/www/cgi-bin">
                        AllowOverride None
                        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                        Require all granted
                        AddHandler cgi-script cgi py sh
                </Directory>
        </IfDefine>
</IfModule>
```

3. add handler in file cgid.load and make soft links

default path: /etc/apache2/mods-available

add the following code

```
AddHandler cgi-script .cgi .pl .py .sh
```

then link

```
sudo ln -s /etc/apache2/mods-available/cgid.load /etc/apache2/mods-enabled/cgid.load
```

4. restart apache2

```
sudo /etc/init.d/apache2 restart
```

5. add target files in /var/www/cgi-bin

don't forget to change the permission of target files

[back](./)

