# URL Shortener

This little tool was a short project to obfuscate usercredentials and URL to a crypted Hash. 
To obfuscate the payload, i used a symetric encryption via aes-256-cbc algorythm.

There is only one Environment variable to configure the Service:
```
-e SHORTENER_ENVIRONMENT=[LOCAL|DEV|QA|LIVE]
```

To generate a new CryptoKey just use:
```
./generate_new_key config/foobar.key
```

If you want to build the container, you have to generate a `Gemfile.lock` with:
```
bundle install
```

You can edit some basic settings for each Environment (you can add some ENV's here) under `config/app.yml`

Pictures:

![alt text](https://preview.ibb.co/i3NG3v/Bildschirmfoto_2017_02_16_um_17_10_48.png "Landing Page")
![alt text](https://preview.ibb.co/m2XG3v/Bildschirmfoto_2017_02_16_um_17_27_45.png "Encryption View")
![alt text](https://preview.ibb.co/kwBnAa/Bildschirmfoto_2017_02_16_um_17_28_02.png "Decryption View")
