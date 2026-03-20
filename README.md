# a regex engine writen by haskell

- regular expression -> regex tokens -> regex ast -> regex nfa -> regex dfa

- ast-tree-test

```mermaid
graph TD
    Root["<b>Concatenate</b><br/>主连接操作"]
    
    Q["<b>Question</b><br/>可选 ?"]
    RestConcat["<b>Concatenate</b><br/>剩余部分连接"]
    
    QChar["<b>CharLiteral</b><br/>'a'"]
    
    Star1["<b>Star</b><br/>克林闭包 *"]
    MidConcat["<b>Concatenate</b><br/>中间连接"]
    
    Union1["<b>Union</b><br/>并集 |"]
    Union2["<b>Union</b><br/>并集 |"]
    EndConcat["<b>Concatenate</b><br/>结尾连接"]
    
    A1["<b>CharLiteral</b><br/>'a'"]
    B1["<b>CharLiteral</b><br/>'b'"]
    B2["<b>CharLiteral</b><br/>'b'"]
    C["<b>CharLiteral</b><br/>'c'"]
    
    Star2["<b>Star</b><br/>克林闭包 *"]
    Dot["<b>CharLiteral</b><br/>'.'"]
    
    Any["<b>AnyChar</b><br/>任意字符"]
    
    Root --> Q
    Root --> RestConcat
    
    Q --> QChar
    
    RestConcat --> Star1
    RestConcat --> MidConcat
    
    Star1 --> Union1
    Union1 --> A1
    Union1 --> B1
    
    MidConcat --> Union2
    MidConcat --> EndConcat
    
    Union2 --> B2
    Union2 --> C
    
    EndConcat --> Star2
    EndConcat --> Dot
    
    Star2 --> Any
    
    classDef root fill:#ff6b6b,stroke:#333,stroke-width:4px,color:#fff
    classDef quantifier fill:#4ecdc4,stroke:#333,stroke-width:2px
    classDef union fill:#ffe66d,stroke:#333,stroke-width:2px
    classDef leaf fill:#95e1d3,stroke:#333,stroke-width:2px
    
    class Root root
    class Q,RestConcat,Star1,MidConcat,EndConcat,Star2 quantifier
    class Union1,Union2 union
    class QChar,A1,B1,B2,C,Dot,Any leaf
```
