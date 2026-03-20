-- main.hs

main :: IO ()
main = do
  let a = "hello, regex expression"

  putStrLn a 


-- regex expression
-- “origin string” -> 依次提取元字符并按照查询
-- regex expression string -> AST -> NFA -> simulate NFA -> output outcome
