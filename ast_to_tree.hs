-- ast_to_tree.hs
-- 输入regex-ast -> 生成md格式的 ast tree 

mermaid_ :: String -> String
mermaid_ context = 
  "```mermaid\n" <> context <> "\n```"


main :: IO ()
main = putStrLn (mermaid_ "hello, world!")

