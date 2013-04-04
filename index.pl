#!/usr/bin/perl -w

use lib "../../../perl-libs";
use Mojolicious::Lite;
use DBI;

my $CONF = require "settings.conf";

my $dbh = DBI->connect($CONF->{database_conn}, $CONF->{database_user}, $CONF->{database_pass}, {RaiseError => 1,AutoCommit=>0});

my $base_rest_url = Mojo::URL->new($CONF->{base_url})->query(api_key => $CONF->{api_key});

get '/' => 'index';
get '/noticias' => sub {
    my $self = shift;
    my $noticias = $dbh->selectall_arrayref("SELECT id_noticia, titulo, intro FROM noticias WHERE publicado=1 LIMIT 10",{Slice=>{}});
    my $json = '[';
    foreach my $n(@$noticias){
	$json .= '{"id":"'.$n->{id_noticia}.'", "title":"'.$n->{titulo}.'", "intro":"'.$n->{intro}.'"}';
    }
    $json .= ']';
    $self->render(json => $noticias);
};
get '/noticia/:id' => sub {
    my $self = shift;
    my $id = $self->param("id");
    my $noticia = $dbh->selectrow_hashref("SELECT id_noticia, titulo, intro, contenido FROM noticias WHERE id_noticia=? AND publicado=1",{Slice=>{}},int($id));
    $self->redirect_to($CONF->{base_url}) if(!$noticia->{id_noticia});
    $self->render(json => {id=> $noticia->{id_noticia}, title=>$noticia->{titulo}, intro=>$noticia->{intro}, contenido=>$noticia->{contenido} });
};
app->start('cgi');

__DATA__

@@ index.html.ep

<html>
  <head>
    <meta charset="utf-8">
    <title>API REST</title>
    <link rel="stylesheet" href="css/bootstrap.min.css" />
    <style>body {padding:60px 0 40px;}</style>
  </head>
  <body>
    <header>
      <div class="container">
        <h1>API REST<span class="label label-info">Beta</span></h1>
        <p class="lead">En desarrollo ...</p>
      </div>
    </header>
    <div class="container">
      <div class="row">
        <div class="span3">
          <ul class="nav nav-list bs-docs-sidenav">
            <li><a href="#noticias"><i class="icon-chevron-right"></i>Lista Noticias</a></li>
            <li><a href="#noticias_id"><i class="icon-chevron-right"></i>Single Noticias</a></li>
          </ul>
        </div>
        <div class="span9">
          <section id="noticias">
            <div class="page-header"><h1>1. Noticias</h1></div>
            <p>Lista de noticias en JSON <code>/noticias/</code></p>
            <pre class="prettyprint">[{"titulo": "Gran polémica por la muerte de Michael Jackson", "intro": "La duda que mantienen los investigadores del Departamento de Policía de Los Ángeles, acerca de la muerte de Michael Jackson es si fue sobredosis de Demerol o ataque al corazón.", "id_noticia": "266"}, {"titulo": "Inminente resolucion de jueza,  sobre caso Blanco", "intro": "Aunque la jueza dicte a fevor de blando no sera definitiva", "id_noticia": "267"}, {"titulo": "El multimillonario Bernard Madoff fue sentenciado el lunes a 150 años en prisión.", "intro": "El castigo solicitado por los fiscales, a raíz de un fraude multimillonario tan amplio que el juez dijo que necesitaba mandar un mensaje simbólico a quienes se vean tentados a imitar el delito del financista.", "id_noticia": "268"}, {"titulo": "Obama se reune con Calderon", "intro": "El presidente de México, Felipe Calderón Hinojosa, propuso al mandatario electo de Estados Unidos, Barack Obama ...,", "id_noticia": "2"}]</pre>
          </section>
          <section id="noticias_id">
            <div class="page-header"><h1>2. Single Noticias</h1></div>
            <p>Información en JSON dado un ID de noticia <code>/noticia/{id}</code></p>
            <pre class="prettyprint">{"intro": "La duda que mantienen los investigadores del Departamento de Policía de Los Ángeles, acerca de la muerte de Michael Jackson es si fue sobredosis de Demerol o ataque al corazón.", "title": "Gran polémica por la muerte de Michael Jackson", "id": "266", "contenido": "El médico Conrad Murray, único testigo de los últimos segundos de vida del \"Rey del pop\" no es sospechoso, sólo un testigo de los hechos\", aseguraron autoridades policiales, que igual investigan al médico personal del músico. Ahora, la familia del cantante espera la realización de una autopsia privada (para acelerar los tiempos), que determine los verdaderos motivos de deceso de la bestia pop.\r\nConrad Murray era médico personal de Michael Jackson desde hacía un mes, pero conocía al cantante desde el 2006, cuando curó a sus hijos de una infección en Las Vegas. Desde entonces, el músico mantuvo un cercano vínculo con el galeno, quien formaba parte de la nómina en la inmensa gira que planeaba el compositor de Thriller.\r\n\"Planeaba algo grande\", señaló el líder espiritual e íntimo amigo de Michael Jackson. Chopra aseguró que el material que preparaba el músico era lo mejor desde Billie Jean, lo que seguramente se traducirá en una gran herencia para Prince I, Paris y Prince II, hijos del \"Rey del pop\".\r\n"}</pre>
          </section>
        </div>
      </div>
    </div>
  </body>
</html>
