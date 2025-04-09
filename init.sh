echo "# Segundo reto de tipo LFI con credenciales expuestas para conectar por SSH y escalar privilegios" >> README.md
git init
git add . 
git commit -m "segundo commit por no cambiar el .sh"
git branch -M main
git remote add origin git@github.com:msanchis/lfi2-challenge.git
git push -u origin main
