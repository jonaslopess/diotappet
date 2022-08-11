<h1 align="center"> XIoT </h1>


Para acessar o help do programa digite:


```bash
sudo ./diotappet help
```

#Para rodar o DIoTAppET é preciso:

1) Clone o diretorio do DIoTAppET:

```bash
git clone https://github.com/jonaslopess/diotappet.git
```

2) Intale o Docker e certifique que ele está funcionando adequadamente.

3) Crie as imagens usadas pelo programa.


Para isso, entre na pasta **/docker** e rode o programa:

```bash
sudo sh make-images
```


Outra forma de fazer a mesma coisa é rodar na pasta **/diotappet**:

```bash
sudo ./diotappet build
```


Observe se ocorre algum erro ao longo da criação das imagens.

Se houver erro, pode ser necessário editar os arquivos Dockerfile dentro de cada pasta individual. Nelas, também existem Init que são executados na construção das imagens.


**Para saber se deu certo, digite**:


```bash
sudo docker images
```

Verifique se as seguintes imagens foram criadas:

```bash
base
wasp-base
gateway-base
goshimer
node
gateway
router
```


4) Execute o DIoTAppET, como por exemplo:


```bash
sudo ./diotappet start
```


Ou ainda, outro exemplo:


```bash
sudo ./diotappet -d 30 -r 10000 -l 8 -g 1 -G 1 -c 1 -C 1 start
```


A cada teste, o DIoTAppET cria uma pasta com o nome do experimento na pasta **/log**. O nome da pasta já indica a configuração do experimento realizado.


