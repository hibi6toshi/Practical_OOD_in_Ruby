# コンポジションでオブジェクトを組み合わせる

コンポジションとは、組み合わされた全体が、単なる部品の集合以上となるように、個別の部品を複雑な全体へと組み合わせる（コンポーズする）行為です。
この章では。オブジェクト指向コンポジションのテクニックについて説明する。

## 自転車をパーツからコンポーズする（８.１）

リファクタリングをいくつか施しながら、次第に継承をコンポジションに置き換えていきます。

### Bicycle クラスを更新する

Bicycle クラスは、現在、継承の階層構造における抽象スーパークラスです。これをコンポジションをつくように変更したいとしましょう。
最初のステップは、まず今あるコードのことを忘れることです。そして自転車はどのようにコンポーズされるべきか考えてみましょう。

Bicycle クラスは、spares メッセージに答える責任があります。「自転車 − パーツ」といった関係がコンポジションであるということは、とても自然なことのように思えます。自転車のパーツ全てを持つオブジェクトを作れば、スペアパーツに関するメッセージはその新しいオブジェクトに移譲できるでしょう。
この新しいクラスを Parts クラスを名づけるのは妥当です。Parts オブジェクトは、自転車のパーツ一覧を保持しておくこと、また、どのパーツがスペアを必要とするのかを知っておく責任を負えます。

```mermaid
sequenceDiagram
    a Bicycle ->>+ The Parts: spares
    The Parts -->>+ a Bicycle: --
```

すべての Bicycle が Parts オブジェクトを必要とします。Bicycle であるということは、Parts を持つことを意味するのです。

```mermaid
classDiagram
  class Bicycle {
  }
  class Parts {
  }
  Bicycle *--> Parts
```

この図は、Bicycle と Parats クタスは線で繋がっています。
あたらしい Bicycle クラスは次のようになるでしょう。

```
class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size = args[:size]
    @parts = args[:parts]
  end

  def spares
    parts.spares
  end
end
```

Bicycle の責任は 3 つになりました。size を知っていくこと、自身の Parts を保持すること、そして spares に応えること。

### Parts 階層構造をつくる

Bicycle のコードの大部分は、パーツを取り扱っていました。Bicycle からより除いた振る舞いは依然として必要なものです。
このコードが再度動くようにするための一番単純な方法は、次のコードのように、単純に Parts の新しい階層構造に対象のコードを移動することです。

```
class Parts
  attr_reader :chain, :tire_size

  def initialize(args = {})
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    {
      tire_size: tire_size,
      chain: chain
    }.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  # subclasses may override
  def post_initialize(_args)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
    '10-speed'
  end
end

class RoadBikeParts < Parts
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    {
      tape_color: tape_color
    }
  end

  def default_tire_size
    '23'
  end
end

class MountainBikeParts < Parts
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
  end

  def local_spares
    {
      rear_shock: rear_shock
    }
  end

  def default_tire_size
    '2.1'
  end
end
```

```mermaid
classDiagram
  class Bicycle {
  }
  class Parts {
  }
  class MountainBikeParts{
  }
  class RoadBikeParts{
  }
  Bicycle *--> Parts
  MountainBikeParts --> Parts
  RoadBikeParts --> Parts
```

ここには抽象 Parts クラスがあります。
Bicycle は Parts から構成されます。Parts は RoadBikeParts と MountainBikeParts という 2 つのサブクラスを持ちます。￥

このリファクタリングを経ても、すべてこれまで通り動きます。
RoadBikeParts か MountainBikeParts のどちらを持とうが、自転車は依然として自信の size と spares を正確に答えられるのです。

これは大きな変更でもなく、大きな改善でもありません。しかし、このリファクタリングのよおっ絵、有益なことが明らかになりました。
そもそも必要だった Bicycle の特有のコードがいかに少なかったです。
Parts 階層構造は、また別のリファクタリングを必要としています。

## Parts オブジェクトをコンポーズする(8.2)

定義に基づけば、パーツのリストは、個々の部品を持ちます。
単一の部品を表すクラスを追加するときが来ました。

すでに単一の Parts クラスを参照するために「parts」という語が使われているところに複数の Part オブジェクトの集まりに言及するために「parts」を使うのは混乱の元です。

今は、Parts オブジェクトがあり、それが Part オブジェクトを複数保持できるだけとしてすすめましょう。

### Part を作る

Bicycle とその Parts オブジェクト間の会話、そして Parts オブジェクトとその Part オブジェクト間の会話です。
Bicycle は Parts に spares を送ります。そして Parts オブジェクトは needs_spare をそれぞれの Part に送ります。

```mermaid
sequenceDiagram
    a Bicycle ->> The Parts: spares
    The Parts ->> a Part: needs_spare
    a Part -->> The Parts: --
    The Parts -->> a Bicycle: --
```

設計をこのように変更すると、新たに Part オブジェクトを作る必要が出てきます。Parts オブジェクトはいまや複数の Part オブジェクトからコンポーズされるようになっています。

```mermaid
classDiagram
  class Bicycle {
  }
  class Parts {
  }
  class Part
  Bicycle *--> Parts
  Parts *--> Part
```

Bicycle は Part オブジェクトを１つ持ち、Parts は複数の Part を持つ。

この Part オブジェクトを新たに導入したことにより、既存の Parts クラスは簡略化され、Part オブジェクトの配列を包む簡潔なラッパーとなりました。Parts は自身の Part オブジェクトのリストを選別し、スペアが必要なものだけを返すことができます。

次のコードは既存の Bicycle、更新された Parts クラス、新たに導入された Part クラスです。

```
class Bicycle
  attr_reader :size, :parts

  def initialize(args = {})
    @size = args[:size]
    @parts = args[:parts]
  end

  def spares
    parts.spares
  end
end

class Parts
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def spares
    parts.select { |part| part.needs_spare }
  end
end

class Part
  attr_reader :name, :description, :needs_spare

  def initialize(args)
    @name = args[:name]
    @description = args[:description]
    @needs_spare = args.fetch(:needs_sparem, true)
  end
end
```

これら 3 つのクラスが存在するようになったので、個々の Part オブジェクトを作れます。

```
chain = Part.new(
  name: 'chain', description: '10-spaeed'
)

road_tire = Part.new(
  name: 'tire_size', description: '23'
)

tape = Part.new(
  name: 'tape_color', description: 'red'
)

mountain_tire = Part.new(
  name: 'tire_size', description: '2.1'
)

rear_shock = Part.new(
  name: 'rear_shock', description: 'Fox'
)

front_shock = Part.new(
  name: 'front_shock', description: 'Manitou', needs_spare: false
)

```

個々の Part オブジェクトは、Parts オブジェクトにひとまとめにしてグループ化できます。

```
road_bike_part = Parts.new([chain, road_tire, tape])
```

以前の階層構造と異なるのは、Bicycle の以前の spares メソッドはハッシュを返しましたが、この変更後の spares メソッドは、Part オブジェクトの配列を返します。
これらのオブジェクトを Part クラスのインスタンスだと考えたくなるかもしれません。
しかし、コンポジションの教えによれば、これらは**Part のロールを担うオブジェクト**と考えるべきです。
これらのオブジェクトは「Part クラスの種類」である必要もありません。その 1 つであるかのように振る舞う必要があるだけです。
つまり、name、description、needs_spare に対応できる必要があります。

### Parts オブジェクトをもっと配列のようにする

このコードは改善の余地がある。
Bicycle の parts と spares メソッドは、同じ種類のものを返すべきな感じがします。しかし、今の時点では戻ってくるオブジェクトは同じように振る舞いません。

```
mountain_bike.spares.size
# -> 3
mountain_bike.parts.size
# -> NoMethodError:
      undifiend method 'size' for #<Parts:...>
```

parts は Parts のインスタンスを返すため size を理解できません。
この 2 つは両方とも配列のように見え、故に配列のように扱ってしまいます。
直近の問題は、Parts に size メソッドを追加することで修正できます。単純に size を委譲するメソッドを実装するだけです。

```
def size
  parts.size
end
```

この変更を加えると、Parts に対して、each や sort しまいには Array とすべてのメソッドに応答して欲しくなります。
Parts を配列のようなものにすればするほど、より配列のように振る舞うことを期待するようになるのです。
Array である Parts をつくることもできる。

```
class Parts < Array
  def spares
    select { |part| part.needs_spare }
  end
end
```

上のコードはかなりストレートな方法で、Parts は Array を特化したものであるという考えを形にしたものです。
この設計には欠陥が隠れています。

```

Part は'+'を Array から継承するため、2 つの Parts は加え合わせられる。
combo_parts =
(mountain_bike.parts + road_bike.parts)

'+'は間違いなく Parts を組み合わせる
combo_parts.size -> 7

しかし、'+'が返すオブジェクトは'spares'を理解できない。
combo_spares.spares
-> NoMethodError: undifiend method 'spares'
for #<Array:...>

mountai_bike.parts.class -> Parts
road_bike.parts.class -> Parts
combo_parts.class -> Array

```

Array には新しい配列を返すメソッドは沢山あり、これらのメソッドは、Array クラスのインスタンスを返すのであり、こちらで定義したサブクラスのインスタンスを返すのではありません。
ここまで、それぞれ異なる Parts の実装を 3 つ見てきました。最初の実装が応えるのは spares と parts メッセージのみでした。配列のようには振る舞いません。ただ配列をもっているだけです。
2 つ目の parts の実装では、size を追加しました。内部配列の size を返すようにしただけでした。
最後の Parts の実装では、Array のサブクラスにしました。したがって、見かけ上は、最大限配列オブジェクトのように振る舞うようになりました。
しかし、上記の例に見られるように Parts のインスタンスはまだ期待はずれの振る舞いをします。

以上から、完璧な解決方法はないことが明らかになりました。難しい決断が迫られています。

複雑さと利便性のおおよそ中間に、次の解決策があります。
次の Parts クラスは size と each を自身の@parts 配列に委譲し、操作と検索のための共通メソッドを得るために。Enumerable をインクルードしています。
このバージョンの Parts は Array の振る舞いを全てもつわけではありません。
しかし、少なくとも Parts ができると主張することはすべて実際に動作します。

```

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each

  iclude Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select { |part| part.needs_spare }
  end
end

```

この Parts インスタンスに＋を送ると、NoMethodError 例外が起きます。しかし、Parts は現在、size、each、そして、Enumerable の全てに応答するようになっていて、間違って Array のように扱った時にのみエラーを発生するようになっています。

再度、動くバージョンの Bicycle、Parts、Part クラスを手に入れました。では、設計を再評価してみましょう。

## Parts を製造する（８.３）

Part オブジェクトは「chain、mountain_tire」などのように保持されています。この四行に表される知識体系について考えてみましょう。
アプリケーションのどこかで、何らかのオブジェクトが Part オブジェクトの作り方を知っている。
この特定の 4 つのオブジェクトがマウンテンバイク用だと知っている必要があります。

この知識量はかなり多く、また、アプリケーションのあちこちに簡単に漏れるでしょう。
個別のパーツは幾つもあるものの、有効なパーツの組み合わせはほんの一部だけです。
ですから、**さまざまな自転車を記述し、その記述をもとに何らかの方法で、正確な Parts オブジェクトをどの自転車にも製造**できれば、全てはより簡単になるのではないでしょうか。

### PartsFactory をつくる

他のオブジェクトを製造するオブジェクトはファクトリーです。ファクトリーという言葉は、単に、オブジェクト指向の設計者が、他のオブジェクトを作るオブジェクト、という概念を簡潔に共有するために用いている語句に過ぎないのです。

次のコードは新たに導入する PartsFactory モジュールです。
これの仕事は、上で挙げられていたような配列を 1 つとって、Parts オブジェクトを製造することです。途中、Part オブジェクトの作成もあると思いますが、そのアクションはプライベートなものです。
外に示す責任は、Parts を作ることです。
この PartsFactory の最初のバージョンは、引数を 3 つ取ります。
config が 1 つと、あとは Part と Parts に使われるクラス名です。このコードの６行目では、Parts の新しいインスタンスを作っています。config の情報をもとに作られた Part オブジェクトの配列を用いて、初期化しています。

```
module PartsFactory
  def self.building(config,
                    part_class = Part,
                    parts_class = Parts)

    parts_class.new(
      config.collect do |part_config|
        part_class.new(
          name: part_config[0],
          description: part_config[1],
          needs_spare: part_config.fetch(2, true)
        )
      end
    )
  end
end
```

このファクトリーは config 配列の構造を知っています。
config の構造に関する知識をファクトリ内におくことによってもたらされる影響は２つあります。
１つ目は、config をとても短く簡潔に表現できることです。Factory が config の内部構造を理解しているので、config をハッシュではなく配列で指定できます。
２つ目は、一度 config を配列に入れると決めたのですから、Parts オブジェクトを作るときは「常に」このファクトリーを使うことが当然になることです。PartsFactory が導入されたので、設定用の配列を使い、簡単に Parts オブジェクトを作れるようになりました。

```
road_config = [
  %w[chain 10-speed],
  %w[tire_size 23],
  %w[tape_color red]
]

mountain_config = [
  ['chain', '10-speed'],
  ['tire_size', '2.1'],
  ['frint_shock', 'Manitou', false],
  ['rear_shock', 'Fox']
]

road_parts = PartsFactory.new(road_config)
mountain_parts = PartsFactory.new(mountain_config)
```

PartsFactory は、設定用の配列と組み合わされ、有効な Parts を作るために必要な知識を隔離します。
この情報は、以前はアプリケーション全体に分散していたものでした。しかし、今はこのクラス１つと、配列２つにおさまっています。

### PartsFactory を活用する

PartsFactory が導入され、稼働し始めたので。Part クラスに再度焦点を当ててみましょう。
PartsFatctory がすべての Part を作るのであれば、Part でこのコード（args.fetch(:needs_spare, true)）を持つ必要はありません。
また、Part からこのコードを取り除いてしまえば、残るものはほとんど何もありません。
Part クラス全体は、単純な OpenStruct で置き換えられるのです。

Ruby の OpenStruct クラスは、これまで登場した Struct クラスとかなり似通っています。
２つの違いは、Struct は初期化時に順番を指定して引数を渡す必要がある一方、OpenStruct では初期化時にハッシュをとり、そこから属性を引き出すことにあります。
Part クラスを取り除くことにはもっともな理由があります。
それによりコードが簡潔になり、今持っているほど複雑なものが今後一切必要無くなるのです。

Part の痕跡を一切取り除くには、まず Part クラスを消し、そして PartsFactory を変え、OpenStruct を使うことで、Part「ロール」を担うオブジェクトを担うオブジェクトを作るようにします。

新しいバージョンの PartsFasctory を示しています。ここでは、部品（part）の作成はリファクタリングされ、自身のメソッドになっています。

```

require 'ostruct'

module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect |part_config|
        create_part(part_config)
    )
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true)
    )
  end
end
```

13 行目（needs_spare: part_config.fetch(2, true)）は、アプリケーション内で唯一 needs_spare のデフォルト値を true に設定する箇所になりました。そのため、Parts を製造する責任は、PartsFactory が単独で負わなければなりません。

## コンポーズされた Bicycle（８.４）

次のコードはコンポジションを使うようになった Bicyclen を示しています。
BIcycle、Parts、PartsFactory、そしてロードバイクとマウンテンバイクの設定用の配列が示されています。

Parts オブジェクトと Part オブジェクトはクラスとして存在することもあるかもしれませんが、それらを包含しているオブジェクトは、それらをロールとして捉えています。

```
class Bicycle
  attr_reader :size, :parts

  def initialize(args = {})
    @size = args[:size]
    @parts = args[:parts]
  end

  def spares
    parts.spares
  end
end

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  # selectはEnumerableのメソッドで、内部的にはeachを使う。
  # eachは@partsに委譲されているので、@partsに対して実行される
  def spares
    select { |part| part.needs_spare }
  end
end

require 'ostruct'
module PartsFactory
  def self.build(config, parts_class = Parts)
    parts_class.new(
      config.collect do |part_config|
        create_part(part_config)
      end
    )
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true)
    )
  end
end

road_config = [
  ['chain', '10-speed'],
  ['tire_size', '23'],
  ['tape_color', 'red']
]

mountain_config = [
  ['chain', '10-spaeed'],
  ['tire_size', '2,1'],
  ['front_shock', 'Manitou', false],
  ['rear_shock', 'Fox']
]
```

この新しいコードは、以前の Bicycle 階層構造とほとんど同じように動作します。唯一の違いは、spares メッセージがハッシュではなく、Part 同様のオブジェクからなる配列を返すことです。

これらのクラスが作られたことによって、随分と簡単に新たな種類の自転車を作れるようになりました。
リカンベントバイクを追加してみます。
３行の設定を書くだけで実装できます。

```
recumbent_config = [
  ['chain', '9-speed'],
  ['tire_size', '28'],
  ['flag', 'tall and orange']
]

recumbent_bike = Bicycle.new(
  size: 'L',
  parts: PartsFactory.build(recumbent_config)
)

recumbent_bike.spares
```

単純にそのパーツを記述するだけで新しい自転車を追加できます。

## コンポジションと継承の選択(8.5)

クラスによる継承は「コード構成のテクニック」であり、クラスによる継承において、振る舞いは複数のオブジェクトに分散されます。そしてそれらのオブジェクトは、メッセージの自動的な委譲によって正しい振る舞いが実行される。というようなクラスの関係に構成されます。
**「オブジェクトを階層構造に構成するコストを払う代わりに、メッセージの委譲は無料で手に入る」**と考えてみましょう。

コンポジションはそれらのコストと利点を逆転させる代替案です。
コンポジションでは、オブジェクト間の関係をクラスの階層構造としてコードに落とし込むことはしません。コンポジションでは、オブジェクトは独立して存在します。そしてその結果、オブジェクトはお互いについて、明示的に知識を持ち、明示的にメッセージを委譲する必要があるのです。
**コンポジションによって、オブジェクトは構造的に独立して存在できるようになります。しかし、それは明示的なメッセージ委譲のコストを払ってのこと**なのです。

**一般的なルールとしては、直面した問題がコンポジションによって解決できるものであれば、まずはコンポジションで解決することを優先すべきです。
コンポジションが持つ依存は、継承が持つ依存よりもはるかに少ないものです**。ですから、コンポジションが第一の選択肢であることは頻繁にあります。

### 継承による影響を認める

継承を使うための賢い決断をするためには、そのコストと利点の明確な理解が求められます。

■ 継承の利点
目指すべきコードの在り方の 4 点「見通しが良いこと」「合理的であること」「利用性が高いこと」「模範的であること」のうち、継承が正しく適用されていれば、2 番目、3 番目、4 番目において優れた結果をもたらします。
継承階層の頂点に近いところで定義されたメソッドの影響力は広範囲に及びます。メソッドに加えられた変更は、継承ツリーを波及していきます。したがって、正しくモデル化された階層構造は極めて合理的です。振る舞いの大きな変更を、コードの小さな変更で成し遂げられるのです。

継承を使った結果得られるコードは、「オープン・クローズド」と特徴つけられたものになります。階層構造は「利用性の高い」ものです。

正しく書かれた階層構造はかんたんに拡張できます。階層構造は、抽象を明らかにし、すべての新しいサブクラスは、少しの具象的な違いを差し込みます。本質的に、その階層構造自体が、階層構造を拡張するコードを書くためのガイドになるのです。

■ 継承のコスト
継承を使う際の懸念事項は次の２つの領域に分けられます。
１つ目の懸念事項は、継承が適さない問題に対して、誤って継承を選択してしまうことです。そもそもモデルが間違っているので、振る舞いが適合できる余地はありません。
この場合、コードを複製するか、再構成せざるを得ないでしょう。

２つ目は問題に対して、継承の適用が妥当であったとしても、自分が書いているコードがほかのプログラマーによって、全く予期していなかった目的のために使われるかもしれないことです。ほかのプログラマーたちは、皆さんが書いた振る舞いを使いたくても、継承が要求する依存を許容できない可能性があります。

適さない問題に継承を利用した場合、継承の利点は問題点になる。（コインの裏表のようなもの）

合理的の反面は、間違ってモデル化された階層構造の頂点近くの変更にかかる膨大なコスト。小さな変更が全てを破壊します。

利用性が高いの反面は、サブクラスが複数の方を混合したものの表現であるときの、振る舞いの追加の不可能さです。
第 6 章の Bicycle 階層構造は、リカンベントマウンテンバイクの必要性が生まれた時に対応できませんでした。階層構造には、すでに MountainBike と RecumbentBike のサブクラスが含まれています。これら２つのクラスの性質を組み合わせ、単一のオブジェクトにするのは、そのままの階層構造では不可能です。

模範的の反面は、混沌です。この混沌は、不適切にモデル化された階層構造を初級プログラマーが拡張しようとした結果もたらされます。
これらの不適切な階層構造は、拡張されるべきではありません。リファクタリングされるべきです。

継承では、「自分が間違っているとき、何が起こるだろう」という問いかけが特別な意味を帯びてきます。継承は、その定義からして深く埋め込まれた依存の集まりを伴うものです。サブクラスは、そのスーパークラスに定義されたメソッドに依存し、それらのスーパークラスへの自動的な委譲にも依存しています。これはクラスによる継承の一番の強さであると同時に、一番の弱さであるとも言えます。サブクラスは変更不可の形で、計画的に、それより上の階層構造内のクラスに結合されているのです。
これらの備え付けの依存が、スーパークラスへ加えられた修正の影響を増幅します。そして、膨大で、広範囲に及ぶ振る舞いの変更が、ほんの少しのコードの変更で達成されます。

### コンポジションの影響を認める

コンポジションで作られたオブジェクトは、継承によって作られたオブジェクトと、次の２つの基本的な点で異なります。
コンポジションによって作られたオブジェクトは、クラスの構造には依存しません。そして、自身のメッセージは自身で委譲します。これらに違いが、異なるコストと利点をもたらします。

■ コンポジションの利点
コンポジションを使うと、次のような小さなオブジェクトが自然と幾つも作られる傾向があります。
それは、責任が単純明快であり、明確に定義されたインターフェースを介してアクセス可能な小さなオブジェクトです。
これらの小さなオブジェクトは単一の責任を持ち、自身の振る舞いを限定してます。それらは「見通しが良い」ものです。つまりコードは簡単に理解でき、変更が起きた場合に何が起こるかが明確ということです。
また、コンポーズされたオブジェクトが階層構造から独立しているということは、コンポーズされたオブジェクトはほんのわずかなコードしか継承せず、それゆえ、それより上の階層構造にあるクラスへの変更によって生じる副作用に悩まされることは一般的にないということを意味しているのです。

本質的に、コンポジションに参加するオブジェクトは小さく、構造的に独立しており、そして、適切に定義されたインターフェースを持ちます。

コンポジションを最大限に活用できれば、結果として、単純で、抜き差し可能であり、しかも拡張性が高く、変更にも寛容なオブジェクトから作られるアプリケーションが出来上がります。

■ コンポジションのコスト
コンポーズされたオブジェクトは多くのパーツに依存します。それぞれの部品は小さく、簡単に理解できるものであったしても、組み合わせられた全体の動作は、理解しやすいとは言えないでしょう。

構造的な独立性の利点は、メッセージの自動的な委譲を犠牲にすることでえられています。コンポーズされたオブジェクトは、明示的にどのメッセージを誰に移譲するかを必ず知っていなければなりません。全く同一の移譲のコードが、幾つもの多岐にわたるオブジェクトによって必要とされる可能性もあります。コンポジションはこのコードを共有するための手段は何も提供してくれません。

これらのコストと利点が示すように、コンポジションは、パーツからなるオブジェクトの、組み立て方のルールを規定するにはとても優れています。しかし、ほぼ同一なパーツが集まっているコードを構成する問題に対してまでは、そこまでの助けになりません。

### 関係の選択

クラスによる継承、モジュールによる振る舞いの共有、そしてコンポジションは、それぞれが解決の対象とする問題に対しては、完璧な解決策です。アプリケーションのコストを下げるための秘訣は、それぞれのテクニックを正しい問題に適用することでしょう。

先人の、継承とコンポジションの利用についてのアドバイス。

- 継承とは、特殊化です。
- 継承が最も適しているのは、過去のコードの大部分を使いつつ、新たなコードの追加が比較的少量の時に、既存クラスに機能を追加する場合です。
- 振る舞いが、それを構成するパーツの総和を上回るのなら、コンポジションを使いましょう。
