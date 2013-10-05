use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'MojoX-ASPXPageForm';
all_from 'lib/MojoX/ASPXPageForm.pm';
author   q{Robert Grimes <rmzgrimes@gmail.com>};
license  'artistic2';

perl_version 5.006;

requires 'Mojo::UserAgent';
requires 'Mojo::Base';

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#MojoX-ASPXPageForm',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/Robert Grimes/MojoX-ASPXPageForm.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=MojoX-ASPXPageForm',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
