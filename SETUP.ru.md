## Установка

### Ставим пакеты для работы Разблокировщика 
`opkg update`

`opkg install tor tor-geoip ipset usign`

`opkg install luci-compat` - для 19.07+ версий OpenWRT 

### Добавляем репозиторий
`echo -e -n 'untrusted comment: OpenWRT usign key of unlocker repo\nRWSAkINO7cGce05420qPyQYWqp9zMSCMflH2CF+kth6s0EnJOS6WLnd+\n' > /tmp/unlocker-repo.pub && opkg-key add /tmp/unlocker-repo.pub`

`! grep -q 'unlocker_repo' /etc/opkg/customfeeds.conf && echo 'src/gz unlocker_repo http://repo.unlocker.xyz' >> /etc/opkg/customfeeds.conf`

### Ставим разблокировщик
`opkg update`

`opkg install luci-app-unlocker`

## Настройка на примере Tor

- Ставим галочку напротив пункта "включить"
- Выбираем подходящий режим прокси (в нашем случае - разблокировка через сеть Tor)
- Выбираем необходимые списки и нажимаем сохранить и применить
![image](https://gitlab.com/Nooblord/luci-app-unlocker/raw/master/screenshots/setup1.ru.png)
- Переходим во вкладку "Конфигурация Tor" и настраиваем аналогично примеру, либо нажимаем кнопку "Сконфигурировать Tor", после чего ***необходимо перезапустить сервис Tor*** соответствующей кнопкой
![image](https://gitlab.com/Nooblord/luci-app-unlocker/raw/master/screenshots/setup2.ru.png)
> Если у вас кастомный конфиг для Tor'а, убедитесь, что он работает на порту 9040 и принимает не только локальный траффик  
> Опция `TransPort 0.0.0.0:9040`
- Нажимаем сохранить и применить, готово!
- Проверяем работу плагина, и если есть ошибки - смотрим журнал

## Возможные проблемы

- В журнале всё хорошо, модуль работает, но всё равно на заблокированных сайтах - заглушка провайдера

Проверьте, присутствует ли в фаерволе цепочка unlocker_check, в LuCI это вкладка Состояние->Межсетевой экран.
Если да, то вероятнее всего провайдер перехватывает DNS запросы и выдаёт вместо IP-адреса искомого ресурса - адрес своей заглушки.
Это можно исправить поставив на роутер DNS-over-TLS или аналогичные сервисы, а в некоторых случаях поможет простая замена DNS на 1.1.1.1 или 8.8.8.8.
