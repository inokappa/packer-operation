# Packer を自動化したい布石

## とりあえず

### なにこれ

packer で EC2 AMI を作っていて、色々と面倒な部分を Rakefile に落とし込んでみた。

### 出来ること

- packer を叩いてイメージの build
- 作成されたインスタンスイメージでインスタンス起動
- 起動したインスタンスに対して Serverspec を使ってテスト

***

## 使い方

### git clone

```sh
git clone https://github.com/inokappa/packer-operation.git
```

### config.yml

`config.sample.yml` を参考に各種情報を事前に設定する。

```yaml
access_key_id: 'AKxxxxxxxxxxxxxxxxxxxxx'
secret_access_key: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
region: 'us-east-1'
user: "root"
key_path: "/pat/to/file.pem"
instance_type: "t2.micro"
vpc_subnet: "subnet-xxxxxxxx"
security_group: "sg-xxxxxxx"
key_name: "file"
tag_name: "instance_name"
image_tag_name: "ami_name"
user_data_path: "userdata.txt"
```

### Packer する準備

#### template ファイルを作成

適当なディレクトリを作成する。

```sh
mkdir  ~/path/to
```

ディレクトリ配下に `Packer` 用の `template` ファイルや `provisioner` する為のファイルを置く。

```sh
cd  ~/path/to
vim example.json
```

### Serverspec 用のテンプレートを作っておく

インスタンスをテストする `Serverspec` 用の `spec` ファイルを作っておく。

```sh
cd spec_linux
vim check_spec.rb
```

このファイルは `rake genspec:linux` を実行するとインスタンスのホスト名ディレクトリ以下に生成される。

```sh
cd spec_win
vim check_spec.rb
```

このファイルは `rake genspec:win` を実行するとインスタンスのホスト名ディレクトリ以下に生成される。

### イメージのビルド

```sh
PACKER_TEMPLATE_PATH=~/path/to/example.json
rake build
```

***

## tasks

### tasks

~~~~
rake build          # Build Image
rake ec2:getpw      # Get logon Password
rake ec2:launch     # Launch EC2 instances
rake ec2:terminate  # Terminate Instance
rake genspec:linux  # Generate Spec File
rake genspec:win    # Generate Spec File
~~~~

### build

`packer build`  を実行して `AMI` を生成する。

```sh
PACKER_TEMPLATE_PATH=~/path/to/example.json
rake build
```

### ec2:launch

生成した `AMI` を使ってインスタンスを作成する。

```sh
rake launch
```

### ec2:getpw

Windows Server のパスワードを取得する。

```sh
rake ec2:getpw
```

### genspec

作成されたインスタンス用 `Serverspec` の `Spec` ファイルを生成 。

```sh
rake genspec:linux
rake genspec:win
```

### spec

インスタンスのテスト。

```sh
rake spec
```

### terminate

インスタンスのターミネート。

```sh
rake ec2:terminate
```
