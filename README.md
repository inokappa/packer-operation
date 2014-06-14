# Packer を自動化したい布石

## とりあえず

 * 一連の `Packer` の操作を `Rake` コマンドで叩けるようにしてみた

***

## 使い方

### git clone

### Packer する準備

#### template 作成

適当なディレクトリを作成する。

~~~~
mkdir  ~/path/to
~~~~

ディレクトリ配下に `Packer` 用の `template` ファイルや `provisioner` する為のファイルを置く。

~~~~
cd  ~/path/to
vim example.json
~~~~

#### Rakefile の修正

`template` ファイルの設定場所に合わせた形で以下の部分を修正する。

~~~~
desc "Build Image"
task :build do
  sh "cd ~/path/to/ && packer build example.json"
end
~~~

### Serverspec 用のテンプレートを作っておく

インスタンスをテストする `Serverspec` 用の `spec` ファイルを作っておく。

~~~~
cd spec_template
vim check_spec.rb
~~~~

このファイルは `rake genspec` を実行するとインスタンスのホスト名ディレクトリ以下に生成される。

### task の実行

~~~~
rake build
~~~~

***

### task

#### build

`packer build`  を実行して `AMI` を生成する。

~~~~
rake build
~~~~

#### launch

生成した `AMI` を使ってインスタンスを作成する。

~~~~
rake launch
~~~~

#### genspec

作成されたインスタンス用 `Serverspec` の `Spec` ファイルを生成 。

~~~~
rake genspec
~~~~

#### spec

インスタンスのテスト。

~~~~
rake spec
~~~~

#### terminate

インスタンスのターミネート。

~~~~
rake terminate
~~~~
