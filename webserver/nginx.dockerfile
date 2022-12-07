# nginx.dockerfile - a dockerfile to create a nginx image 
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
# 
# Distributed under the MIT License. See LICENSE for more information.
#
FROM nginx:alpine

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
