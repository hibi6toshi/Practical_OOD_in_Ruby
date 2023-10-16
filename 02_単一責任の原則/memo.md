# メモ

```
コードは次のようにあるべきでしょう

- 見通しが良い(Transparent): 変更するコードにおいても、そのコードの依存するところにおいても、変更がもたらす影響が明白である。
- 合理的(Reasonable): どんな変更であっても、かかるコストは変更がもたらす利益にふさわしい。
- 利用性が高い(Usable): 新しい環境、予期していなかった環境でも再利用できる。
- 模範的(Exemplary)：　コードに変更を加える人が、上記の品質を自然と保つようなコードになっている。

(p.37)
```

「利用性が高い」 は最初、DIP の話っぽいなと思った。けど、Adapter とか Strategy もそれっぽいので、基本的な方針なんだろなぁ。

```
データではなく、振る舞いに依存する。
attr_reader　を使うと、Rubyは自動でインスタンス変数用の単純なラッパーメソッドをつくります。
> 例）
attr_reader :cog としたとき、デフォルトの実装はこう

def cog
  @cog
end

このcogメソッドは、コード内で唯一コグ（cog）が何を意味するかをわかっている箇所です。
@cogを数カ所でc（直接）参照していいて、@cogを修正する必要が生じた場合、何箇所も修正しなければならなくなる。
しかし、@cogがメソッドで包まれていれば、コグが意味するものを変えてしまいます。
コグについて独自のメソッドを実装すればいいのです。

シンプルな再実装
def cog
  @cog * unanticipated_adjustment_factor
end

より複雑な実装
def cog
  @cog + (foo? ? bar_adjustment : baz_adjustment)
end
(p.47)
```

カプセル化の具体的なメリットっぽい。
今まで具体的なメリットはわからなかったので新鮮。

```
class A
  attr_reader :data
  def initialize(data); @data=data end
  def diameters
    # 0はリム、１はタイヤ
    data.collect { |cell|
      cell[0] + (cell[1] * 2)}
  end
end
@data = [[622, 20], [622, 23], [559, 30], [559, 40]]

@dataは複雑なデータを含んでいるため、ただインスタンス変数を隠蔽するだけでは不十分。
diametersメソッドは直径を計算するだけではなく、配列のどこを見ればリムとタイヤがあるのかを知っている。
配列の構造に依存している。
=> 配列の構造が変わると、(@dataを)参照ているところ全てを変更する必要がある。
(p.49)
```

```
class B
  attr_reader :wheels
  def initialize(data)
    @wheels = wheelify(data)
  end
  def diameters
    wheels.collect { |wheel|
      wheel.rim + (wheel.tire * 2) }
  end
  # これで誰でもwheelにrim/tireを送れる

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.collect { |cell|
      Wheel.new(cell[0], cell[1]) }
  end
end

Rubyでは簡単に意味と構造を分けられます。RubyのStructクラスを使って構造を包み隠すことができます。
こちらのdiametersメソッドは、配列の内部構造について何も知りません。
diametersが知っているのは、wheelsメッセージが何か列挙できるものを返し、その一つ一つがrimとtrimに応答するということです。
(p.50)
```

構造自体に意味はないんだなと思った。（配列: data の添字が 0:リム、1:タイヤという構造のとき、「添字 0 にリムを入れる絶対的な法則性」みたいなものはない。故に構造自体に意味はない。）
そしてこれは当たり前だが、意外と忘れがちで、「構造に意味を持たせてしまう」というミスは犯しがちな気がする。。。

改善例では、wheel.rim、wheel.tire でアクセスできるようになる。
意味が明確になり、誰でも wheel に rim/tire を送れるようになる。

```
入力されるものをコントロールできる場合は、利用性の高いオブジェクトを渡すようにしましょう。
しかし、 **複雑な構造を受け取ることを強いられる場合は、その複雑さは自身からも見えないところに隠す**ようにしましょう。
```

```
メソッドから余計な責任を抽出する。
単一責任であることによって、メソッドの変更も再利用も簡単になる。

def diameters
  @wheels.collect { |wheel|
    wheel.rim + ( wheel.tire * 2) }
end

このメソッドは二つの責務を持っている。
wheelを繰り返し、それぞれのwheelの直径を計算している。
これらを二つに分けて単純化する。

# 最初に - 配列を繰り返し処理する
def diameters
  @wheels.collect { |wheel| diameter(wheel) }
end

# 次に - 「1つ」の車輪の直径を計算する
def diameter(wheel)
  wheel.rim + ( wheel.tire * 2 )
end
```

メソッドの分割も必要。単一責任を意識して。
そのメソッドが何をするものか？　を一言で表せるようなレベルまで。
