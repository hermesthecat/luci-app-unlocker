Разблокировщик
========

Модуль для [LuCI](https://github.com/openwrt/luci), позволяющий обойти различные виды IP-блокировок.
Был разработан, что бы помочь легко сконфигурировать VPN, Tor и другие сетевые утилиты для пропускания необходимого (например заблокированного провайдером) трафика по заданным спискам прямо на роутере под управлением OpenWRT.
Списки возможно добавлять свои, или использовать уже подготовленные.

На данный момент реализован функционал работы в связке с Tor и Wireguard и авто-обновление списка заблокированных IP.

**[Гайд по установке](https://gitlab.com/Nooblord/luci-app-unlocker/blob/master/SETUP.ru.md)**

Unlocker
========

This is an [LuCI](https://github.com/openwrt/luci) module which helps you bypass ISP restrictions based on IP-blocking.
Unlocker was developed to help you easily configure VPN or any other proxy service to proxy only blocked/restricted traffic right on your OpenWRT-powered router.

Currently module works together with Tor or Wireguard and there are IP blocklists for Russia included.

**[Installation guide](https://gitlab.com/Nooblord/luci-app-unlocker/blob/master/SETUP.en.md)**

License
--------

This app is licensed under the terms of the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt)