-- ast.hs
-- core: To build a regex expression engine just to build a finite automaton

module Ast (
  Regex(..),
  Token,
  ParseError(..),
  ParseResult,
  token_build,
  makeParser,
  parseRegex
) where


-- ADT
data Regex
  = CharLiteral Char
  | Concatenate Regex Regex
  | Union Regex Regex  -- |
  | Star Regex  -- * 克林闭包 -> 前一个字符出现零次或多次
  | Plus Regex -- 正闭包 -> 前一个元素可以出现至少一次
  | Question Regex -- ? -> 0 or 1
  | AnyChar  -- . 指代任意字符
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

data ParseError 
  = ParseError String Int 
  deriving (Show)

type ParseResult = Either ParseError (Regex, Parser)

-- Either
-- data Either e a
--   = Left e
--  | Right a

-- meta char
meta_char :: String
meta_char = "^$|*+?()."

-- 判断是否为元字符 -> 等价于 `elem` 函数
is_meta_char :: Eq a => a -> [a] -> Bool
is_meta_char _ [] = False
is_meta_char x (y:ys) = x == y || is_meta_char x ys

text :: String 
text = "a?(a|b)*(b|c).*/."
test_regex :: Regex
test_regex = Union (CharLiteral 'a') (CharLiteral 'b') 



token_build :: String -> [Token]
token_build [] = []
token_build ('/':c:cs) = Char c : token_build cs
token_build (c:cs)
  | is_meta_char c meta_char = Special c : token_build cs
  | otherwise = Char c : token_build cs

-- ----Parser

-- 初始化创建 Parser
makeParser :: [Token] -> Parser
makeParser ts = Parser ts 0

peekToken :: Parser -> Maybe Token
peekToken (Parser [] _) = Nothing
peekToken (Parser (t:_) _) = Just t

nextToken :: Parser -> Either ParseError (Token, Parser)
nextToken (Parser [] ptr) = Left $ ParseError "Unexpected EOF" ptr
nextToken (Parser (t:ts) ptr) = Right (t, Parser ts (ptr + 1))


-- 递归下降解析器
parseRegex :: Parser -> ParseResult
parseRegex parser = parseUnion parser

parseUnion :: Parser -> ParseResult
parseUnion parser = do
  (term, p1) <- parseConcat parser
  case peekToken p1 of
    Just (Special '|') -> do
      (_, p2) <- nextToken p1
      (right, p3) <- parseUnion p2
      return (Union term right, p3)
    _ -> return (term, p1)

parseConcat :: Parser -> ParseResult 
parseConcat parser = do
  case peekToken parser of
    Just (Char _) -> go
    Just (Special '.') -> go
    Just (Special '(') -> go
    _ -> return (Empty, parser)
  where
    go = do
        (first, p1) <- parseFactor parser
        (rest, p2) <- parseConcat p1
        if rest == Empty
            then return (first, p2)
            else return (Concatenate first rest, p2)

parseFactor :: Parser -> ParseResult
parseFactor parser = do
  (atom, p1) <- parseAtom parser
  case peekToken p1 of
    Just (Special '*') -> do 
        (_, p2) <- nextToken p1
        return (Star atom, p2)
    Just (Special '+') -> do
        (_, p2) <- nextToken p1
        return (Plus atom, p2)
    Just (Special '?') -> do
        (_, p2) <- nextToken p1
        return (Question atom, p2)
    _ -> return (atom, p1)

parseAtom :: Parser -> ParseResult
parseAtom parser = 
  case peekToken parser of
    Just (Char c) -> do
      (_, p) <- nextToken parser
      return (CharLiteral c, p)
    Just (Special '.') -> do
      (_, p) <- nextToken parser
      return (AnyChar, p)
    Just (Special '(') -> do
      (_, p1) <- nextToken parser
      (expr, p2) <- parseUnion p1
      case peekToken p2 of
        Just (Special ')') -> do
            (_, p3) <- nextToken p2
            return (expr, p3)
        _ -> Left $ ParseError "Expected closing ')'" (pos p2)
    Just t -> Left $ ParseError ("Unexpected token in atom: " ++ show t) (pos parser)
    Nothing -> Left $ ParseError "Unexpected EOF" (pos parser)



main :: IO ()
main = do
  putStrLn $ "Input: " ++ text
  let ts = token_build text
  putStrLn $ "Tokens: " ++ show ts
  let parser = makeParser ts
  case parseRegex parser of
      Left (ParseError err idx) -> putStrLn $ "Error at " ++ show idx ++ ": " ++ err
      Right (ast, _) -> putStrLn $ "AST: " ++ show ast
