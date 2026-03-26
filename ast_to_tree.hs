-- ast_to_tree.hs
-- 输入regex-ast -> 生成md格式的 ast tree  

import Ast

-- generate 'mermaid' code
mermaid_ :: String -> String
mermaid_ context = 
  "```mermaid\n" <> context <> "\n```"

-- generate node io
nodeID :: Int -> String
nodeID n = "Node" ++ show n

-- AST -> Mermaid graph_context
astToMermaid :: Regex -> String
astToMermaid ast = 
  let (graph_context, _) = generateGraph ast 0
  in "graph TD\n" ++ graph_context

-- generate craph_context
-- input: 
--    Regex_ast and Token's index
-- output:
--    marmaid's code
--    the next accessible ID after processing this subtree
--    the ID of current node
generateGraph :: Regex -> Int -> (String, Int)

-- 处理叶子节点
generateGraph (CharLiteral c) idx =
  let
    -- 定义当前节点
    me = "\r" ++ nodeID idx ++ "[\"<b>" ++ [c] ++ "<\b><br/>\"]"
  in (me ++ "\n", idx + 1)

generateGraph (AnyChar ) idx = 
  let
    me = "\r" ++ nodeID idx ++ "[\"AnyChar .\"]"
  in (me ++ "\n", idx + 1)

generateGraph (Empty ) idx = 
  let
    me = "\r" ++ nodeID idx ++ "[\"Empty\"]"
  in (me ++ "\n", idx + 1)



-- 处理subtree
generateGraph (Concatenate l_subtree r_subtree) idx = 
  let
    me = "\r" ++ nodeID idx ++ "[\"<b>" ++ "Concatenate" ++ "<\b><br/>\"]"

    -- process left subtree
    leftIdx = idx + 1
    (leftCode, nextIdx) = generateGraph l_subtree leftIdx
    edgeLeft = "\r" ++ nodeID idx ++ "-->" ++ nodeID leftIdx

    -- process right subtree
    rightIdx = nextIdx
    (rightCode, finalIdx) = generateGraph r_subtree rightIdx
    edgeRight = "\r" ++ nodeID idx ++ "-->" ++ nodeID rightIdx

    -- combined code
    fullCode = unlines [me, leftCode, edgeLeft, edgeRight, rightCode]
  in  (fullCode, finalIdx)

generateGraph (Union l_subtree r_subtree) idx = 
  let
    me = "\r" ++ nodeID idx ++ "[\"<b>" ++ "Union" ++ "<\b><br/>\"]"

    -- process left subtree
    leftIdx = idx + 1
    (leftCode, nextIdx) = generateGraph l_subtree leftIdx
    edgeLeft = "\r" ++ nodeID idx ++ "-->" ++ nodeID leftIdx

    -- process right subtree
    rightIdx = nextIdx
    (rightCode, finalIdx) = generateGraph r_subtree rightIdx
    edgeRight = "\r" ++ nodeID idx ++ "-->" ++ nodeID rightIdx

    -- combined code
    fullCode = unlines [me, leftCode, edgeLeft, edgeRight, rightCode]
  in  (fullCode, finalIdx)

 -- [树枝] 星号 Star
generateGraph (Star r) idx =
  let 
      me = "\r" ++ nodeID idx ++ "(\"Star *\")"
      childIdx = idx + 1
      (childCode, finalIdx) = generateGraph r childIdx
      edge = "\r" ++ nodeID idx ++ " --> " ++ nodeID childIdx
      fullCode = unlines [me, edge, childCode]
  in (fullCode, finalIdx)

-- [树枝] 加号 Plus
generateGraph (Plus r) idx =
  let 
      me = "\r" ++ nodeID idx ++ "(\"Plus +\")"
      childIdx = idx + 1
      (childCode, finalIdx) = generateGraph r childIdx
      edge = "\r" ++ nodeID idx ++ " --> " ++ nodeID childIdx
      fullCode = unlines [me, edge, childCode]
  in (fullCode, finalIdx)

-- [树枝] 问号 Question
generateGraph (Question r) idx =
  let 
      me = "\r" ++ nodeID idx ++ "(\"Question ?\")"
      childIdx = idx + 1
      (childCode, finalIdx) = generateGraph r childIdx
      edge = "\r" ++ nodeID idx ++ " --> " ++ nodeID childIdx
      fullCode = unlines [me, edge, childCode]
  in (fullCode, finalIdx)




-- text = "abs(a|c)+c.a/.(b|a)*"
text = "a?(a|b)*(b|c).*/."

main :: IO ()
main = do
  putStrLn $ "Input: " ++ text

  -- 解析 token
  let ts = token_build text
  putStrLn $ "Tokens: " ++ show ts

  -- generate regex-ast
  let parser = makeParser ts

  -- pattern matching regex-ast and Parser instance
  case parseRegex parser of
      Left (ParseError err idx) -> putStrLn $ "Error at " ++ show idx ++ ": " ++ err
      Right (ast, _) -> do
        putStrLn $ "AST: " ++ show ast

        putStrLn "---------------------------------------------"
        putStrLn (astToMermaid ast)
        putStrLn "---------------------------------------------"
        -- generate mermaid graph
        -- astToMermaid ast