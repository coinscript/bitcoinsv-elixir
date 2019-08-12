# bitcoinsv-elixir

Since bitcoin SV network has started, we need a cloud wallet server which can address the need for mainstream users, especially for business / organization / merchants who wants to be connected to the MetaNet. which is an important platform for the future
IoV (Internet of Value). The core difference between classical internet and MetaNet is the additional blockchain layer on top of TCPIP. since many important feature requires a bitcoin node for operations on addresses, signatures, transactions and scripts,
we need a flexiable and high performance node implementation for billions of users (humans & machines).

## Simple bitcoinsv wallet

how to send data embeded tx
```
import Bitcoin.Cli

w = new_wallet "8b559565ec6754895b6f378fa935740e34bb7d9b515ade65c6dc06081e3b63c7" # private key only for testing
get_balance w
outputs = [%{type: "safe", data: "我真牛🍺 "}]
transfer w, outputs
```

normal tx(p2pkh)
```
outputs = [{
    "1PVCqdqyEWGbzyBRLXptjG3n3AzaJtrsFp", # address
    1000 # amount (satoshis)
    }]
```

## use as a lib

```
{:bitcoin, github: "coinscript/bitcoinsv-elixir"}
```

## License

See the LICENSE file in the project root.

## Contributing

Please fork this repository to your own account, create a feature/{short but descriptive name} branch on your own repository and submit a pull request back to develop.

Any kind of contributions are super welcome. commercial developer please contact OWAF for Full Documentation and Membership.


