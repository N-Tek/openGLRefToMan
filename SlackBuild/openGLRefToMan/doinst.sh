if [ -f /usr/man/whatis.orig ]; then
    cp --verbose --archive /usr/man/whatis.orig /usr/man/whatis
fi
cp --verbose --archive /usr/man/whatis /usr/man/whatis.orig
/usr/sbin/makewhatis -u -v -s 3
