package Config::General::Easy ;
require Exporter ;
our @ISA = qw(Exporter Config::General);
our @EXPORT=qw() ;

use Carp ;
use Data::Dumper ;
use Dir::Which q/which/ ;
use Config::General ;

use strict ;

our $VERSION = "0.1" ;

#--------------------
sub new
{
  my($type,%h) = @_ ;
  my($this,$EasyConfigFile,$EasyDefaultConfig,$EasyForcedConfig) ;
  my($arg,$obj,$default,$config,$forced) ;
  
  if (exists($h{"-EasySearchPath"}))
  {
    $arg->{"-defaultpath"} = $h{"-EasySearchPath"} ;
    delete $h{"-EasySearchPath"} ;
  }

  if (exists($h{"-EasyEnvPath"}))
  {
    $arg->{"-env"} = $h{"-EasyEnvPath"} ;
    delete $h{"-EasyEnvPath"} ;
  }

  if (exists($h{"-ConfigFile"}))
  {
    $arg->{"-entry"} = $h{"-ConfigFile"} ;
    $EasyConfigFile = which(%$arg) ;
    $this->{EasyConfigFile} = $EasyConfigFile ;
    return undef unless defined $EasyConfigFile ;
    $h{"-ConfigFile"} = $EasyConfigFile ;
  }
  
  if (exists($h{"-EasyDefaultConfig"}))
  {
    $EasyDefaultConfig = $h{"-EasyDefaultConfig"} ;
    delete $h{"-EasyDefaultConfig"} ;
  }
  else { $EasyDefaultConfig = {} ; }

  if (exists($h{"-EasyForcedConfig"}))
  {
    $EasyForcedConfig = $h{"-EasyForcedConfig"} ;
    delete $h{"-EasyForcedConfig"} ;
  }
  else { $this->{EasyForcedConfig} = {} ; }

  my $this = new Config::General(%h) ;
  
  my %conf = $this->getall() ;
  
  %{$this->{EasyDefaultConfig}} = %$EasyDefaultConfig ;
  $this->{EasyForcedConfig} = $EasyForcedConfig ;
  %{$this->{EasyConfig}} = %$EasyDefaultConfig ;

  my ($k,$v) ;
  $this->{EasyConfig}{$k} = $v while ($k,$v)=each(%conf) ;
  $this->{EasyConfig}{$k} = $v while ($k,$v)=each(%{$this->{EasyForcedConfig}}) ;

  bless $this,$type ; 
  return $this ;
}

#--------------------
sub getConfigFile
{
  my($this) = @_ ;
  return $this->{EasyConfigFile} ;
}

#--------------------
sub getall
{
  my($this) = @_ ;
  return %{$this->{EasyConfig}} ;
}  
  
#--------------------
sub get
{
  my($this,$var) = @_ ;
  
  return $this->{EasyConfig}{$var} if exists($this->{EasyConfig}{$var}) ;
  croak "'$var' not found !" ;
}

#--------------------
sub has
{
  my($this,$var) = @_ ;
  
  return exists($this->{EasyConfig}{$var}) ;
}

0.1 ;


=head1 NAME

Config::General::Easy - Easy use of Config::General for simple ordinary configuration files

=head1 SYNOPSIS

  use Config::General::Easy ;

  my $config = new Config::General::Easy(
    -ConfigFile => "myappli.conf"
    , -EasySearchPath => "$FindBin::Bin:~:/etc" 
    , -EasyEnvPath => "MYAPPLI_PATH" 
    , -EasyDefaultConfig => \%default
    , -EasyForcedConfig => \%args
    ) ;

  my %conf = $config->getall() ;

  print $config->get("workingdir") ;
  print $config->get("dbfile") if $config->has("dbfile") ;
  print $config->get("verbose") ;

=head1 DESCRIPTION

The Easy object is a Config::General object with 2 supplementary methods get and has. 
The Easy object accepts both a set of default values and a set of forced values.
A path string can be provide to the constructor, to locate the file in a list of directories.
A name of environment variable can be provide to the constructor, which is used, like the PATH variable, to locate the configuration file.

=head1 FUNCTIONS

=head2 new

Create a easy object. Arguments recognized by a Config::General object can be provided here, and some new ones can be added :

=head3 Arguments

=over 4

=item -EasySearchPath

A path-like string, used to locate the configuraton file in a list of directories.

=item -EasyEnvPath

A name of an environment variable, which is used, like the PATH variable, to locate the configuration file.

=item -ConfigFile

The name of the configuration file.

=item -EasyDefaultConfig

A hash containing a set of default values for the variables.

=item -EasyForcedConfig

A hash containing forced values for some variables.

=back

  my $config = new Config::General::Easy(
    -ConfigFile => "myappli.conf"
    , -EasySearchPath => "$FindBin::Bin:~:/etc" 
    , -EasyEnvPath => "myappli_path" 
    , -EasyDefaultConfig => \%default
    , -EasyForcedConfig => \%args
    ) ;

=head2 getall

  Like Config::General::getall, return a hash structure which represents the whole config.
  
  %conf = $config->getall() ;

=head2 get

  Return the value of a variable.
  
  $verbose = $config->get("verbose") ;

=head2 has

  Return true if the variable exists, false otherwise.

  $verbose = $config->has("verbose") ;

=head2 getConfigFile

  Return the name of the current config file.

=head1 EXAMPLES    

  With the following config file, named myappli.conf :

  # workingdir 
  #   default: .
  workingdir /var/myprog/

  # dbfile 
  #   default: myprog.db
  # dbfile myprog.db

  # verbose
  #  default: 1
  verbose 0

  <id>
    user john
    group beatles
  </id>

  aString defined in config file

and the following program, named myappli :
  
  use strict ;
  use Config::General::Easy ;
  use Data::Dumper ;
  use Getopt::Long ;
  use Env::Path ;

  my $default = { 
    "workdir" => "."
    , "dbfile" => "myappli.db"
    , "verbose" => 1
    , "id" => { user => "paul" , group => "beatles" } 
    , "aString" => "defined in program"
    } ;

  my %args ;

  GetOptions(
          \%args
          , "workingdir=s" 
          , "dbfile=s"
          , "verbose"
          , "aString=s"
          , 
  ) ;

  my $config = new Config::General::Easy(
    -ConfigFile => "myappli.conf"
    , -EasySearchPath => "$FindBin::Bin:~:/etc" 
    , -EasyEnvPath => "MYAPPLI_PATH" 
    , -EasyDefaultConfig => $default
    , -EasyForcedConfig => \%args
    ) ;

  my %conf = $config->getall() ;

  print $config->get("workingdir") ;
  print $config->get("dbfile") ;
  print $config->get("verbose") ;
  print $config->get("debug") if $config->has("debug") ;
  print Dumper $config->get("id") ;
  print $config->get("aString"), "\n" ;

we get :

    ./myappli 
    myappli.db
    0
    $VAR1 = {
              'group' => 'beatles',
              'user' => 'john'
            };
    defined in config file
    
    ./myappli -v -aString "defined in argument"
    myappli.db
    1
    $VAR1 = {
              'group' => 'beatles',
              'user' => 'john'
            };
    defined in argument

=head1 SEE ALSO

L<Config::General>, L<Dir::Which>.

=head1 AUTHOR

Jacquelin Charbonnel, C<< <jacquelin.charbonnel at math.cnrs.fr> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-config-general-easy at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-General-Easy>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::General::Easy

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-General-Easy>

=item * CPAN Ratings

L<http://cpanratings.perl.org/c/Config-General-Easy>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-General-Easy>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-General-Easy>

=back

=head1 COPYRIGHT & LICENSE

Copyright Jacquelin Charbonnel E<lt>jacquelin.charbonnel at math.cnrs.frE<gt>

This software is governed by the CeCILL-C license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-C
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-C license and that you accept its terms.

=cut

=head1 AUTHOR

Jacquelin Charbonnel, C<< <jacquelin.charbonnel at math.cnrs.fr> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-Config-General-Easy at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-General-Easy>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config-General-Easy

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-General-Easy>

=item * CPAN Ratings

L<http://cpanratings.perl.org/c/Config-General-Easy>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-General-Easy>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-General-Easy>

=back

=head1 COPYRIGHT & LICENSE

Copyright Jacquelin Charbonnel E<lt> jacquelin.charbonnel at math.cnrs.fr E<gt>

This software is governed by the CeCILL-C license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-C
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-C license and that you accept its terms.

