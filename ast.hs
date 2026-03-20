-- ast.hs
-- core: To build a regex expression engine just to build a finite automaton

-- ADT
data Regex
  = CharLiteral Char
  | Concatenate Regex Regex
  | Union Regex Regex  -- |
  | Star Regex  -- * 克林闭包 -> 前一个字符出现零次或多次
  | Plus Regex -- 正闭包 -> 前一个元素可以出现至少一次
  | Qusetion Regex -- ? -> 0 or 1
  | Dot Regex -- . 指代任意字符
  | Empty
  deriving (Show, Eq)

-- priority: low -> hight
-- union -> concatenate -> star, add, question,

-- Token ADT
data Token
  = Char Char
  | Special Char
  | Trans Char
  deriving (Show, Eq)

-- Parser ADT
data Parser = Parser
  {
    tokens :: [Token]
  , pos :: Int
  }
  deriving (Show)

data ParseError = ParseError String Int deriving (Show)

type ParseResult = (Regex, Parser)

-- meta char
meta_char :: String
meta_char = "^$|*+?()"

-- 判断是否为元字符 -> 等价于 `elem` 函数
is_meta_char :: Eq a => a -> [a] -> Bool
is_meta_char _ [] = False
is_meta_char x (y:ys) = x == y || is_meta_char x ys

text :: String 
text = "(a|b)*(b|c).*/."
test_regex :: Regex
test_regex = Union (CharLiteral 'a') (CharLiteral 'b') 



token_build :: String -> [Token]
token_build [] = []
token_build (c:cs)
  | is_meta_char c meta_char = Special c : token_build cs
  | is_meta_char c "/" = Trans c : token_build cs
  | otherwise = Char c : token_build cs

-- ----Parser

-- 初始化创建 Parser
makeParser :: [Token] -> Parser
makeParser ts = Parser ts 0

-- 查看当前 Token
peekToken :: Parser -> Maybe Token
peekToken (Parser [] _) = Nothing
peekToken (Parser (t:_) _) = Just t

-- 消耗当前 Token
nextToken :: Parser -> (Token, Parser)
nextToken (Parser [] ptr) = error $ "The index is unexpect..." ++ show ptr
nextToken (Parser (t:ts) ptr) = (t, Parser ts (ptr + 1))


-- 递归下降解析器
parseRegex :: Parser -> ParseResult
parseRegex parser = parseUnion parser

parseUnion :: Parser -> ParseResult
parseUnion parser = do
  (left_regex, parser') <- parseConcat parser
  case peekToken parser' of
    Just (Special '|') -> do
      -- 匹配到 | ， 消耗当前token, 并递归解析右子式
      (_, parser'') <- nextToken parser'
      (right_regex, parser''') <- parseUnion parser''
      return (Union left_regex right_regex, parser''')
    _ -> return (left_regex, parser')


parseConcat :: Parser -> ParseResult 
parseConcat parser = do
  (first, parser') <- parseAtom parser  
  case peekToken parser' of
    Just (Special '|') -> 
      return (first, parser')
    -- Just (Special '*') ->
      -- ..

    -- no special char, keeping concatation
    _ -> do
      (rest, parser'') <- parseConcat parser'
      return (Concatenate first rest, parser'')

parseAtom :: Parser -> ParseResult
parseAtom parser = 
  case peekToken parser of
    Just (Char c) -> do
      (_, parser') <- nextToken parser
      return (CharLiteral c, parser')
    -- Nothing -> 
      --Left (ParseResult "unexpected end of input" (pos parser))





main :: IO ()
main = putStrLn (show (test_regex))
