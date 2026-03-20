-- ast_to_tree.hs
-- 输入regex-ast -> 生成md格式的 ast tree 

import Ast

mermaid_ :: String -> String
mermaid_ context = 
  "```mermaid\n" <> context <> "\n```"


text = "abs(a|c)+c.a/.(b|a)*"

main :: IO ()
main = do
  putStrLn (mermaid_ "hello, world!")

  putStrLn $ "Input: " ++ text
  let ts = token_build text
  putStrLn $ "Tokens: " ++ show ts
  let parser = makeParser ts
  case parseRegex parser of
      Left (ParseError err idx) -> putStrLn $ "Error at " ++ show idx ++ ": " ++ err
      Right (ast, _) -> putStrLn $ "AST: " ++ show ast

