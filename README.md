# Koast Freeroam
![Koast Freeroam](https://i.imgur.com/Pg5QXZU.jpg)

[![Discord](https://img.shields.io/badge/Discord-Koast_Freeroam-5765ec?logo=discord&logoColor=white)](https://discord.com/invite/vzew9mDpYn)
[![Telegram Channel](https://img.shields.io/badge/Telegram-Koast_Freeroam_Channel-35ade1?logo=telegram)](https://t.me/koastfreeroam)
[![Telegram Chat](https://img.shields.io/badge/Telegram-JCGTeam_Chat-35ade1?logo=telegram)](https://t.me/jcgteamchat)

**Koast Freeroam** - популярный русскоязычный сервер в игре Just Cause 2: Multiplayer Mod, разрабатываемый JCGTeam с 2017 года.

## Состав репозитория
* `lua` - Папка с дополнительными функциями для модулей.
* `scripts` - Папка основных модулей сервера.
* `UFixJcmpServer.bat` - Запуск консоли сервера с поддержкой русской кодировки.
* `SettingUp.bat` - Настраивает код перед публикацией. Вам, вероятнее всего, это не потребуется.

## Инструкции
### Создание официального сервера
https://steamcommunity.com/sharedfiles/filedetails/?id=576213539

**ВАЖНО!** Для правильной работы модулей, включите `IKnowWhatImDoing` в конфиге сервера.

Папки `scripts`, `lua` и `UFixJcmpServer.bat` должны находиться в корневой папке сервера.\
Запускайте сервер через `UFixJcmpServer.bat`, чтобы в консоли отображались русские буквы вместо иероглифов.

Удалите `server.db` если вы уже когда-то запускали сервер с другими модулями. Это требуется во избежание непредвиденных ошибок.

### Выдача привилегий
1. Выдача префиксов и доступа к некоторым командам
    - Перейдите в scripts/3-Tags/server и прочитайте `README.txt`.
    - Перезагрузите модуль `3-Tags` (reload 3-Tags) или перезайдите на сервер.

2. Выдача админ-панели и остальных функций
    - Перейдите в scripts/3-AdminSystem/server и откройте файл `admin_server.lua`.
    - Найдите строчку `local firstAdmin = ""` и впишите туда свой SteamID.\
**Пример:**\
```local firstAdmin = "STEAM_0:0:90087002"```
    - Перезагрузите модуль `3-AdminSystem` (reload 3-AdminSystem) или сервер (reloadall).
    - Для выдачи прав другим игрокам, передйтие в `ACL` через админ-панель и настройте нужные разрешения. (Открыть админ-панель: **P**)

### Страницы новостей
Перейдите в scripts/23-News и создайте нужные .txt файлы.
* `newsRU.txt` - страница новостей на русском языке.
* `newsEN.txt` - страница новостей на английском языке.

### Реклама в игровом чате
Перейдите в scripts/8-Tips и создайте нужные .txt файлы, затем построчно вписывайте нужные вам сообщения.
* `adsRU.txt` - список рекламных сообщений на русском языке.
* `adsEN.txt` - список рекламных сообщений на английском языке.

### Трассы для гонок
Трассы для гонок находятся в scripts/57-Racing/Courses.\
Для создания новых трасс, используйте [редактор карт](https://github.com/dreadmullet/JC2-MP-MapEditor "JC2-MP-MapEditor") от dreadmullet.
