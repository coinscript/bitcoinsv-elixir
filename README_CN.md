#bitcoinsv-elixir

由于比特币SV网络已经启动，我们需要一个云钱包服务器，它可以满足主流用户的需求，特别是对于想要连接到MetaNet的商业/组织/商家。这是未来的重要平台
IoV（价值互联网）。经典互联网和MetaNet的核心差异是TCPIP之上的附加区块链层。因为许多重要功能需要比特币节点来处理地址，签名，事务和脚本，
我们需要为数十亿用户（人和机器）提供灵活，高性能的节点实现。

## 当前状态

- 完整的协议解析器和序列化
- 白皮书的脚本解释器
- 连接和接受来自其他同行的连接
- 将区块链同步到postgres数据库
- 带有第三方API的SPV模式
- 可配置模块（您可以插入自己的对等处理程序，连接管理器，存储引擎等）


## 路线图

- 存储正确处理重组和优化
-  Mempool具有0-conf和双重花费检测
- 令牌化智能合约服务, 允许它跨多个节点运行


## 用法

 - 安装和安装
 -  Elixir
 - 数据库
 - 配置文件
 - CLI操作
    在项目目录下运行 `iex -S mix` 进入 shell.
    - 检查地址的余额
        ```elixir
        > import Bitcoin.Cli
        > my_wallet = new_wallet("Your private key in hex string")
        > get_balance(my_wallet)
        888888 # satoshis
        ```
    - 将比特币发送到可选费用的地址
        ```elixir
        # 继续
        > outputs = [
        >   {"1EMHJsiXjZmffBUWevGS5mWdoacmpt8vdH", 800} # donate 800 satoshi bsv to bitcoinsv-elixir team
        > ]
        > transfer(my_wallet, outputs)
        "the transaction's txid"
        > transfer(my_wallet, outputs, 2) # you can set the fee per byte, default is 1 satoshi/byte
        "the transation's txid"
        ```

 - 仪表板API
 - 用户存款状态API
 - 用户撤销状态API
 - 与Cold Wallet签订交易



##运行节点

要启动节点，请取消注释dev.exs中的以下行

#config：bitcoin，：node，[]

为避免滥用网络，您可能只想连接到本地节点，例如：

配置：比特币，：节点，[
连接：[{127,0,0,1}]
]

检查（config.exs）[config / config.exs]以获取更多详细信息。

## 执照

请参阅项目根目录中的LICENSE文件。

## 贡献

请将此存储库分配到您自己的帐户，在您自己的存储库中创建一个功能/ {简短但描述性的名称}分支，并提交拉回请求以进行开发。

任何形式的贡献都是非常受欢迎的。商业开发者请联系OWAF获取完整文档和会员资格。