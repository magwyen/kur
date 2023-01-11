Root parolasını bilmediğim için ilk önce root parolasını değiştirdim.

Bunun için grup ekranında “e” bastım. Gelen ekranda linux16 ile başlayan yerde “ro” kısmını “rw init=/sysroot/bin/sh” olarak değiştirdim sonra “Ctrl+X” bastım ve bu adımları uygulamadım.

```bash
chroot /sysroot
passwd root 
touch /.autorelabel 
exit
reboot
```

Belirlediğim parola ile sisteme giriş yapabildim. “README” dosyasını okudum fakat sistemde bir yavaşlama hissetim. Bu yüzden “top” komutu ile sistemde ki yükü kontrol ettim ve belirli aralıklarla “stress” adında bir şeyin çalıştığını gördüm. 

Zamanlanmış bir görev diye düşündüm ve “crontab -e” kontrol ettim. Burada göremedim, /etc/crontab gün, aylık, saatlik bölümlerini kontrol ettim. Başka bir kullanıcının crontab dosyasında vardır belki diye “/etc/shadow” dosyasına baktığımda başka bir kullanıcı göremedim. 

“journalctl -u stress” ile baktım bir script ile tetiklenmediğini fark ettim ve servis olduğunu düşündüm.

```bash
systemctl stop stress && systemctl disable stress
```

crontab -e ile baktığımda /opt/ dizinin içinde script dosyaları olduğunu gördüm ve iki tane “.script1 ve .script2” dosyası olduğunu öğrendim.

script1 dosyasında “dd” komutu ile “/var/tmp” dizinine sürekli imaj aldığını gördüm bunu açıklama satırına çevirdim ve disk alanı açmak için aldığı yedekleri sildim. Script2 dosyası apache2 servisi ile ilgiliydi onu olduğu gibi bıraktım.

“nmtui” komutu ile network ayarlarıma bakmak istediğimde Network Manager servisinin çalışmadığını gördüm bunun için bunları yaptım.

```bash
systemctl start NetworkManager && systemctl enable NetworkManager && systemctl status NetworkManager
```

nmtui ile;

```bash
Addresses : 192.168.1.56
Gateway : 192.168.1.1
DNS Servers : 8.8.8.8
```

Yaptım ve NetworkManager yeniden başlattım fakat olmadı.

İnternette biraz araştırma yaptığımda /etc/resolve.conf dosyasını öğrendim bunu kontrol ettim.

/etc/resolve.conf dosyasını kontrol ettiğimde 8.8.8.7 olduğunu gördüm bunu düzeltmek istedim fakat root olmama rağmen “permissions” hatası aldım internette baktığımda dosyanın kilitli olabileceğini söylüyordu.

```bash
$lsattr /etc/resolv.conf
----ia------------- /etc/resolv.conf # Dosyanın kilitli olduğunu ifade ediyor.
```

Dosyanın kilidini kaldırdım ve düzenledim sonra tekrar kilitlemek için bu komutu çalıştırdım.

```bash
$chattr -i /etc/resolve.conf # Kilidini açtım ve düzenledim
$chattr +ia /etc/resolv.conf # Tekrar kilitledim
```

“ip a” yapıp ip adresime baktığımda ip adresimin değişmediğini gördüm ve sistemi kapatıp yeniden açtığımda düzeldi.

 ip adresimi kontrol ettiğimde onunda değiştiğini gördüm. Artık sisteme ssh ve ping atabiliyor oldum ve sistem internet çıkabilir bir hale geldi.

Sistemi güncellemek istedim fakat burada sadece bu repoları gördüm CentOS-Base.repo yoktu.

```bash
$yum clean all && yum update

(1/4): epel/x86_64/group_gz                                                                                                               |  99 kB  00:00:00
(2/4): extras/7/x86_64/primary_db                                                                                                         | 249 kB  00:00:00
(3/4): epel/x86_64/updateinfo                                                                                                             | 1.0 MB  00:00:01
(4/4): epel/x86_64/primary_db                                                                                                             | 7.0 MB  00:00:01
```

Kontrol etmek için repoları listeledim.

```bash
$yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * epel: mirrors.nxthost.com
 * extras: mirror.bursabil.com.tr
repo id                                                       repo name                                                                                    status
epel/x86_64                                                   Extra Packages for Enterprise Linux 7 - x86_64                                               13,732
extras/7/x86_64                                               CentOS-7 - Extras                                                                               515
repolist: 14,247
```

/etc/yum.repos.d/ dizininde CentOS-Base.repo vardı fakat kontrol ettiğimde enabled bölümlerinin “0” olduğunu fark ettim. CentOS-Base.repo dosyası’nın “enabled=0” bölümlerini 1 ile değiştirdim.

```bash
sed -i s/"enabled=0"/"enabled=1"/g /etc/yum.repos.d/CentOS-Base.repo
```

Tekrar güncelleme için update komutunu çalıştığımda CentOS-Base.repo geldi ve sistemi bütün paketleri güncelledim.

```bash
$yum clean all && yum update
base                                                                                                                                      | 3.6 kB  00:00:00
centosplus                                                                                                                                | 2.9 kB  00:00:00
epel                                                                                                                                      | 4.7 kB  00:00:00
extras                                                                                                                                    | 2.9 kB  00:00:00
updates                                                                                                                                   | 2.9 kB  00:00:00
(1/8): base/7/x86_64/group_gz                                                                                                             | 153 kB  00:00:00
(2/8): epel/x86_64/group_gz                                                                                                               |  99 kB  00:00:00
(3/8): epel/x86_64/updateinfo                                                                                                             | 1.0 MB  00:00:00
(4/8): extras/7/x86_64/primary_db                                                                                                         | 249 kB  00:00:00
(5/8): base/7/x86_64/primary_db                                                                                                           | 6.1 MB  00:00:02
(6/8): centosplus/7/x86_64/primary_db                                                                                                     | 7.6 MB  00:00:03
(7/8): epel/x86_64/primary_db                                                                                                             | 7.0 MB  00:00:03
(8/8): updates/7/x86_64/primary_db                                                                                                        |  19 MB  00:00:04
```

Apache2 servisini çalıştırdım ve “enable” hale getirdim;

```bash
systemctl start httpd && systemctl enable httpd && systemctl status httpd
```

Güvenlik duvarından apache2  kullandığı 80 portuna izin verdim.

```bash
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
firewall-cmd --list-all
```

Fakat /var/www dizinin sahiplikleri yüzünden siteyi görüntüleyemedim bunun için apache servisinin gurubu ve sahipliğini verdim;

```bash
chown -R apache:apache /var/www
```

Ayrıca ssh ile bağlanırken “X11 forwarding request failed on channel 0” hatası aldığım için “xauth” paketini de yükledim.

Apache2 servisini güncellemeden önce direkt çalışmıyordu. Güncelleyince düzeldi ama neden olduğunu öğrenmek istedim. “” yaptığımda;

```bash
$apachectl configtest
AH02291: Cannot access directory '/etc/httpd/logs/' for main error log
AH00014: Configuration check failed
```

Burada “/etc/httpd/logs” dizinine ulaşamadığını gösteriyor. Bunu kontrol etmek için;

```bash
$ls -all /etc/httpd
drwxr-xr-x.  2 root root   82 Apr 21  2020 conf.d
drwxr-xr-x.  2 root root  146 Apr 21  2020 conf.modules.d
lrwxrwxrwx.  1 root root   19 Apr 21  2020 logs -> ../../var/log/httpd
lrwxrwxrwx.  1 root root   29 Apr 21  2020 modules -> ../../usr/lib64/httpd/modules
lrwxrwxrwx.  1 root root   10 Apr 21  2020 run -> /run/httpd
```

Yaptığımda “/etc/httpd/logs” dizinin bir sembolik bağ olarak “/var/log/httpd” bağlı. Bu dosyayı bulamadığı içinde servis çalışmıyor. Bu dizini oluşturduğumuzda servis çalıştı.

```bash
mkdir /var/log/httpd
```