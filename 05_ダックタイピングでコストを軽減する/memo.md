# ダックタイピングでコストを削減する

## ダックタイピングを理解する(5.1)

Ruby における、オブジェクトの振る舞いについての一連の想定は、パブリックインターフェースへの信頼というかたちで行われます。オブジェクトの使い手は、そのクラスに木にする必要はなく、また、気にするべきではありません。クラスはオブジェクトがパブリックインターフェースを獲得するための一つの方法でしかないのです。
クラスという方法で獲得するパブリックインターフェースは、オブジェクトが持ついくつかのパブリックメソッドの一つでしかないこともあります。

重要なのは、オブジェクトが何で「あるか」ではなく、何を「する」かなのです。

ダックタイプを説明する最善の方法は、ダックタイプを使わない場合どうなるかを検討することです。

### ダックを見逃す

Tip の mechanic パラメータに含まれるオブジェクトに prepare_bicycles メソッドを送っています。
Trip が持つクラスはどんなクラスでも良い。

```
class Trip
  attr_reader :bicycles, :customers, :vehicle

  # このmechanic　引数は、どんなクラスのものでも良い
  def prepare(mechanic)
    mechanic.prepare_bicycles(bicycles)
  end

  # ...
end

# このクラスのインスタンスを渡すことになったとしても、動作する。
class Mechanic
  def prepare_bicycles(bicycles)
    bicycles.each { |bicycle| prepare_bicycle(bicycle) }
  end

  def prepare_bicycle(bicycle)
    # ...
  end
end
```

シーケンス

```mermaid
sequenceDiagram
    someobject ->>+ a Trip: prepare(mechanic)
    a Trip ->>+ a Mechanic: prepare_bicycles(bicycles)
    a Mechanic -->>- a Trip: --
    a Trip -->>- someobject: --
```

この prepare メソッドは、prepare_bicycles に応答できるオブジェクトを受け取る、ということに依存している。

### 問題を悪化させる

整備士に加え、旅行のコーディネーターと運転手も含まれる。コードパターンに従い、TripCoordeinator と Driver クラスを作るとする。

```

# コーディネーターと運転手を追加
class Trip
  attr_reader :bicycles, :customers, :vehicle

  # prepareでは異なる3つのクラスを名前で参照している上に、
  # それぞれに実装されている具体的なメソッドを知っている。これは危険！
  def prepare(prepares)
    prepares.each do |prepare|
      case preparer
      when Mechanic
        prepare.prepare_bicycles(bicycles)
      when TripCoordinator
        prepare.buy_food(customers)
      when Driver
        prepare.gas_up(vehicle)
        prepare.fill_water_tank(vehicle)
      end
    end
  end
end

class TripCoordinator
  def buy_food(customers)
    # ...
  end
end

class Driver
  def gas_up(vehicle)
    # ...
  end

  def fill_water_tank(vehicle)
    # ...
  end
end
```

設計の創造力がクラスに制限されていると、送っているメッセージを理解し無いオブジェクトに予期せず対応しなければならなくなったとき、それらの新しいオブジェクトが理解「する」メッセージを探しにいくでしょう（→ 上の例だと、buy_food 　とかですね。）

しかし、引数はそれぞれ異なるクラスのものであり、異なるメソッドを実装しています。そのため、case 文での対応でクラスを切り替えることが必要になります。

prepare メソッド内の新たな依存を数えてみましょう。このメソッドは特定のクラスに依存していて、他のクラスは役に立ちません。また、これらのクラスの具体的なメソッド名に依存しています。

### ダックを見つける

依存を取り除く鍵は、「Trip の prepare メソッドは単一の目的を果たすためにあるので、その引数も単一の目的を共に達成するために渡されてくるということを認識すること」です。
どの引数も同じ理由のためにここに存在し、その理由自体は引数の背後にあるクラスとは関係ありません。
**それぞれの引数のクラスの、既存の動作に関する知識に引きずられることは避けねばなりません。その代わりに、prepare が何を必要とするのかについて考えましょう。**

prepare メソッドは、旅行を準備すること（prepare）を望みます。その引数も、旅行の準備に協力しようとやってきます。
prepare が引数のその動作を単に信頼すれば、設計はより簡潔になるでしょう。

prepare において、引数のクラスを想定しなくする。代わりにそれが、「準備するもの（Preparer）」であることが想定されています。

```mermaid
sequenceDiagram
    someobject ->>+ a Trip: prepare(prepares)
    a Trip ->>+ missing 'Preparer': prepare_bicycles(bicycles)
    missing 'Preparer' -->>- a Trip: --
    a Trip ->>+ missing 'Preparer': buy_food(customers)
    missing 'Preparer' -->>- a Trip: --
    a Trip ->>+ missing 'Preparer': gas_up(vehicle)
    missing 'Preparer' -->>- a Trip: --
    a Trip ->>+ missing 'Preparer': fill_water_tank(vehicle)
    missing 'Preparer' -->>- a Trip: --
    a Trip -->>- someobject: --
```

次のステップは、prepare メソッドがそれぞれの Preparer に、どんなメッセージを送れば有益かを問うことでしょう。
この視点で考えれば、prepare_trip です。

Tirp の prepare メソッドは、その引数が prepare_trip に応答できる複数の prepare であることを想定するようになっています。

```mermaid
sequenceDiagram
    someobject ->>+ a Trip: prepare(prepares)
    loop [prepares]
      a Trip ->>+ a 'Preparer': prepare_trip(self)
      a 'Preparer' ->>- a Trip: requset_additional_info
      a Trip -->>+ a 'Preparer': addtional_info_responce
      a 'Preparer' -->>- a Trip: --
      a Trip -->>- someobject: --
    end
```

-> 引数は self なんだという感想。ハッシュで渡した方が安全じゃないかなぁと思ったけど、更新する必要があるなら、self の方がいいか。。。

Preparer とは一体どんな類のものでしょうか。現時点では、具体的な存在は全くありません。Preparer は抽象であり、ある案におけるパブリックインターフェースの取り決めです。設計上の想像でしかありません。
prepare_trip を実装するオブジェクトは、Preparer です。逆に言えば、Preparer と相互作用するオブジェクトに必要なのは、それが Preparer のインターフェースを実装していると信頼することだけです。この根底にある抽象に一度気づけば、コードを修正するのは簡単でしょう。Mechainc と TripCoordinator、そして Driver は、Preparer のように振る舞うべきです。つまり、prepare_trip を実装するべきなのです。

```
# 新しい設計。preparaメソッドは引数が複数のPreparerであることを想定しています。
class Trip
  attr_reader :bicycle, :customer, :vehicle

  def prepare(prepares)
    prepares.each do |prepare|
      prepare.prepare_trip(self)
    end
  end
end

# 全ての準備者(Preparer)は、
# prepare_tripに応答するダック
class Mechanic
  def prepare_trip(trip)
    trip.bicycle.each do |bicycle|
      prepare_bicycle(bicycle)
    end
  end

  # ...
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up
    fill_water_tank(vehicle)
  end
end
# このprepareメソッドは、新しいPreparerを受け入れる際に、変更が強制されることはありません。
# また、必要に応じて追加のPreparerを作るのも簡単です。
```

### ダックタイピングの影響

最初の例では、prepare は具象クラスに依存していました。直近で見た例では、prepare はダックタイプに依存しています。この二つの例の間にある道筋は、依存が満載で複雑なコードの茂みを通り抜けています。

## ダックを信頼するコードを書く（５.２）

ダックタイピングをどれだけ活用できるかは、クラスを跨ぐインターフェースによって利益を享受できる箇所を見つける能力にかかっています。
設計上で難しいことは、ダックタイプが必要であることに気づくこと、そのインターフェースを抽象化することです。

### 隠れたダックを認識する

多くの場合において、まだ見つけられていないダックタイプが既に存在し、既存のコードに潜んでいます。よく用いられるコーディングパターンの中には、隠れたダックの存在を示唆するものがあります。次のものダックで置き換えられます。

- クラスで分岐する case 文
- kind_of? と is_a?
- responds_to?

### ダックを信頼する

kind_of？や is_a？、responds_to?の使用とクラスにとって分岐する case 文が示唆するのは、未特定のダックの存在です。それぞれの場合で、コードは「あなたが誰だか知っている。なぜならば、『あなたが何をするのかを知っているから』」と言っているのと同然です。
この知識は、共同作業するオブジェクトへの信頼が欠けていることをあらわにしています。

###　ダックタイプを文章化する
最も単純なダックタイプは、単にパブリックインターフェースの取り決めとしてだけ存在するものです。
この章のコード例は、そのような類のダックを実装しています。いくつかの異なるクラスが prepare_trip を実装しているので、Preparer のように扱えます。

ダックタイプを作るときは、そのパブリックインターフェースの文章化とテストを、両方ともしなければなりません。幸い優れたテストは最高の文章でもあります。ですから、既に半分は終わっているものでしょう。

### ダック間でコードを共有する

この章では、Preparer ダックはそれぞれが、そのインターフェースに要求される振る舞いについて、各クラスで独自のバージョンを用意しています。
Mechanic、Driver、そして TripCoodinator のそれぞれが prepare_trip メソッドを実装しています。
このメソッドのインターフェースのみを共有し、実装は共有しません。

### 賢くダックを選ぶ

ここまでの例では、そのすべてにおいて、何のメッセージをオブジェクトに送るかを決めたために、kind_of?や responds_to?　を使うべきではないことをはっきりと述べてきました。ですが、同じことをやっても、受けの良いコードもあります。

次のコードは、Ruby on Rails フレームワークからの例です。（active_record/relataions/fider_methods.rb）
この例では、入力された値にどのように対処するかを決めるために、明らかにクラスを利用しています。

このメソッドには find(:first) メソッドと同じ引数を全て渡せる。

```
def first(*args)
  if args.any?
    if args.first.is_a?(Integer) || (logged? && !args.first.is_a?(hash))
      to_a.first(*args)
    else
      apply_finder_options(args.first).first
    end
  else
    find_first
  end
end
```

この例と前の例の多いな違いは、確認されているクラスの安定性です。
first の Integer や Hash への依存は、Ruby のコアクラスへの依存です。first よりもはるかに安定しています。Integer や Hash が変わる可能性、それも first にも変更を強制するかたちで変わる可能性は、極端に低いものでしょう。

## ダックタイピングへの恐れを克服する(5.3)

###　　静的型付けによるダックタイピングの無効化
動的型付けを恐れるプログラマーはコード内でオブジェクトのクラスを精査する傾向にあります。
この検査こそ、まさに動的型付け言語の力を削ぐものであり、ダックタイプの利用を不可能にしているのです。

静的型付け言語の特徴

- コンパイラがコンパイル時に型エラーを発見してくれる
- 可視化された型情報は、文書の役割も果たしてくれる
- コンパイルされたコードは最適化され、高速に動作する

以下の対応する仮定を認める場合にのみ、上記の利点はプログラミング言語における強みとなるでしょう。

- コンパイラが型を検査しない限り、実行時の型エラーが起こる
- 型がなければプログラマーはコードを理解できない。プログラマーはオブジェクトのコンテキストからその型を推測することができない
- 一連の最適化がなければ、アプリケーションの動作は遅くなりすぎる

動的型付け言語の特徴

- コードは逐次実行され、動的に読み込まれる。そのため、コンパイル/make 　のサイクルがない
- ソースコードは明示的な型情報を含まない
- メタプログラミングがより簡単

これらの特性は、以下の仮定を認める場合に強みになります。

- アプリケーション全体の開発は、コンパイル/make のサイクルがない方が高速
- 型宣言がコードに含まれないときの方が、プログラマーにとって理解するのが簡単そのコンテキストからオブジェクトの型は推測できる
- メタプログラミングは、あることが望ましい機能
