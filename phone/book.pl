use warnings;
use Mojolicious::Lite;
use Mojo::mysql;

use Data::Dumper;

my $mysql = Mojo::mysql->strict_mode('mysql://root@/test');
my $db = $mysql->db;

print Dumper($mysql);

get '/' => sub {
	my ($self, $list);
	$self = shift;

	$list = $db->query('select * from book');

	$self->render(
		'template'	=> 'book',
		'list'		=> $list,
		'command'	=> 'create',
		'txt'		=> '',
		'id'		=> '',
		'mess'		=> ''
	);
};

get '/edit' => sub {
	my ($self, $list, $text, $mess);
	$self = shift;

	$list = $db->query('select * from book');
	if ($self->param('id')) {
		$text = $db->query('select * from book where id=?', $self->param('id'))->hash;
	}
	else {
		$mess = 'Нет id записи';
	}

	$self->render(
		'template'	=> 'book',
		'list'		=> $list,
		'command'	=> 'save',
		'txt'		=> $text->{'text'},
		'id'		=> $text->{'id'},
		'mess'		=> $mess
	);
};

post '/save' => sub {
	my ($self, $list, $text, $mess, $id);
	$self = shift;

	unless (length($self->param('txt')) == 12) {
		$mess = 'Номер телефона должен содержать 12 цифр';
	}
	if ($self->param('txt') && !$self->param('id') && !$mess) {
		$db->query('insert into book (text) values (?)', $self->param('txt'));
	}
	elsif ($self->param('txt') && $self->param('id') && !$mess) {
		$db->update('book', {'text' => $self->param('txt')}, {'id' => $self->param('id')});
	}
	else {
		$mess = 'Введите номер телефона';
	}

	$list = $db->query('select * from book');

	$self->render(
		'template'	=> 'book',
		'list'		=> $list,
		'command'	=> 'edit',
		'txt'		=> $self->param('txt'),
		'id'		=> $self->param('id'),
		'mess'		=> $mess
	);
};

get '/delete' => sub {
	my ($self, $list, $mess);
	$self = shift;

	if ($self->param('id')) {
		$db->delete('book', {'id' => $self->param('id')});
	}
	else {
		$mess = 'Нет id записи';
	}

	$list = $db->query('select * from book');

	$self->render(
		'template'	=> 'book',
		'list'		=> $list,
		'command'	=> 'create',
		'txt'		=> '',
		'id'		=> '',
		'mess'		=> ''
	);
};

app->start('daemon', '--reload',	'--listen', 'http://*:8000');
__DATA__

@@ book.html.ep
<!DOCTYPE html>
<html>
	<head>
		<title>Welcome</title>
		<link rel="shortcut icon" href="<%= url_for '/favicon.ico' %>">
	</head>
	<body>

	<ul>
% while (my $next = $list->hash) {
			<li><%= $next->{'text'} %> <a href="/edit?id=<%= $next->{'id'} %>">edit</a> <a href="/delete?id=<%= $next->{'id'} %>" onclick="javascript:alert('Удаляем -<%= $next->{'text'} %>-?')">delete</a></li>
% }
	</ul>
	<form action="/save" method="post" >
		<div style="color:red;"><%= $mess %></div>
		<table width="250" cellpadding="3" cellspacing="3" border="0">
			<tr>
				<td>+<input type="number" name="txt" maxlength="12" oninput="maxLengthCheck(this)" value="<%= $txt %>"></td>
				<td width="60"><input type="submit" value="<% if ($command eq 'create') { %>Добавить<% } else { %>Сохранить<% } %>"></td>
			</tr>
		</table>
		<input type="hidden" name="id" value="<%= $id %>">
		
	</form>
	<script>
		function maxLengthCheck(object)
		{
			if (object.value.length > object.maxLength)
				object.value = object.value.slice(0, object.maxLength)
		}
	</script>
	</body>
</html>

