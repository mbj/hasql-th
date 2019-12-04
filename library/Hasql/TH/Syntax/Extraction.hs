module Hasql.TH.Syntax.Extraction where

import Hasql.TH.Prelude
import Hasql.TH.Syntax.Ast
import qualified Language.Haskell.TH as TH
import qualified Hasql.TH.Syntax.Parsing as Parsing
import qualified Hasql.TH.Syntax.Projections.InputTypeList as InputTypeList
import qualified Hasql.TH.Syntax.Projections.OutputTypeList as OutputTypeList
import qualified Hasql.TH.Syntax.Rendering as Rendering
import qualified Hasql.Encoders as Encoders
import qualified Hasql.Decoders as Decoders


data Statement = Statement ByteString [Encoder] [Decoder]

data Encoder = Encoder TH.Name Bool Int Bool

data Decoder = Decoder TH.Name Bool Int Bool

statement :: Text -> Either Text Statement
statement _quote = do
  _preparableStmt <- ast _quote
  _inputTypeList <- InputTypeList.preparableStmt _preparableStmt
  _outputTypeList <- OutputTypeList.preparableStmt _preparableStmt
  _encoderList <- traverse encoder _inputTypeList
  _decoderList <- traverse decoder _outputTypeList
  let _sql = Rendering.toByteString (Rendering.preparableStmt _preparableStmt)
  return (Statement _sql _encoderList _decoderList)

rowlessStatement :: Text -> Either Text Statement
rowlessStatement _quote = do
  _preparableStmt <- ast _quote
  _inputTypeList <- InputTypeList.preparableStmt _preparableStmt
  _encoderList <- traverse encoder _inputTypeList
  let _sql = Rendering.toByteString (Rendering.preparableStmt _preparableStmt)
  return (Statement _sql _encoderList [])

ast :: Text -> Either Text PreparableStmt
ast = first fromString . Parsing.run (Parsing.quasiQuote Parsing.preparableStmt)

encoder :: TypecastTypename -> Either Text Encoder
encoder (TypecastTypename _name _nullable _dimensions _arrayNullable) =do
  _identText <- identText _name
  encoderName _identText <&> \ _name' ->
    Encoder _name' _nullable _dimensions _arrayNullable

encoderName :: Text -> Either Text TH.Name
encoderName = \ case
  "bool" -> Right 'Encoders.bool
  "int2" -> Right 'Encoders.int2
  "int4" -> Right 'Encoders.int4
  "int8" -> Right 'Encoders.int8
  "float4" -> Right 'Encoders.float4
  "float8" -> Right 'Encoders.float8
  "numeric" -> Right 'Encoders.numeric
  "char" -> Right 'Encoders.char
  "text" -> Right 'Encoders.text
  "bytea" -> Right 'Encoders.bytea
  "date" -> Right 'Encoders.date
  "timestamp" -> Right 'Encoders.timestamp
  "timestamptz" -> Right 'Encoders.timestamptz
  "time" -> Right 'Encoders.time
  "timetz" -> Right 'Encoders.timetz
  "interval" -> Right 'Encoders.interval
  "uuid" -> Right 'Encoders.uuid
  "inet" -> Right 'Encoders.inet
  "json" -> Right 'Encoders.json
  "jsonb" -> Right 'Encoders.jsonb
  "enum" -> Right 'Encoders.enum
  name -> Left ("No value encoder exists for type: " <> name)

decoder :: TypecastTypename -> Either Text Decoder
decoder (TypecastTypename _name _nullable _dimensions _arrayNullable) = do
  _identText <- identText _name
  decoderName _identText <&> \ _name' ->
    Decoder _name' _nullable _dimensions _arrayNullable

decoderName :: Text -> Either Text TH.Name
decoderName = \ case
  "bool" -> Right 'Decoders.bool
  "int2" -> Right 'Decoders.int2
  "int4" -> Right 'Decoders.int4
  "int8" -> Right 'Decoders.int8
  "float4" -> Right 'Decoders.float4
  "float8" -> Right 'Decoders.float8
  "numeric" -> Right 'Decoders.numeric
  "char" -> Right 'Decoders.char
  "text" -> Right 'Decoders.text
  "bytea" -> Right 'Decoders.bytea
  "date" -> Right 'Decoders.date
  "timestamp" -> Right 'Decoders.timestamp
  "timestamptz" -> Right 'Decoders.timestamptz
  "time" -> Right 'Decoders.time
  "timetz" -> Right 'Decoders.timetz
  "interval" -> Right 'Decoders.interval
  "uuid" -> Right 'Decoders.uuid
  "inet" -> Right 'Decoders.inet
  "json" -> Right 'Decoders.json
  "jsonb" -> Right 'Decoders.jsonb
  "enum" -> Right 'Decoders.enum
  name -> Left ("No value decoder exists for type: " <> name)

identText :: Ident -> Either Text Text
identText = \ case
  QuotedIdent a -> Right a
  UnquotedIdent a -> Right a