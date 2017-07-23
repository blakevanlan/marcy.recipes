SITE_DIR=~/ws/marcy.recipes

printf "\n Uploading to Github...\n"

cd ${SITE_DIR}
git commit -m "Site regenerated." -a
git push

printf "\nSite sucessfully uploaded!"
printf "\nVisit marcy.recipes to see the changes."
printf "\nPress enter to close...\n"
read