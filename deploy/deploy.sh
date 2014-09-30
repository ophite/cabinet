cd /home/pydev/trunk/pydev/cabinet
sudo svn up
#sudo python manage.py collectstatic
sudo chown -R www-data /home/pydev/trunk/pydev/cabinet/
sudo /etc/init.d/apache2 restart

