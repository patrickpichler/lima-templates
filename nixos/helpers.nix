{ }:
let
  deepMerge =
    lhs: rhs:
    lhs
    // rhs
    // (builtins.mapAttrs (
      rName: rValue:
      let
        lValue = lhs.${rName} or null;
      in
      if builtins.isAttrs lValue && builtins.isAttrs rValue then
        deepMerge lValue rValue
      else if builtins.isList lValue && builtins.isList rValue then
        lValue ++ rValue
      else
        rValue
    ) rhs);

  parseEnv =
    fileContent:
    let
      lines = builtins.split "\n" fileContent;
      nonEmptyLines = builtins.filter (
        line: builtins.isString (line) && line != "" && !(builtins.substring 0 1 line == "#")
      ) lines;
      parsed = builtins.listToAttrs (
        builtins.map (
          line:
          let
            parts = builtins.filter (line: builtins.isString line) (builtins.split "=" line);
            name = builtins.head parts;
            value = builtins.concatStringsSep "=" (builtins.tail parts);
          in
          {
            name = name;
            value = value;
          }
        ) nonEmptyLines
      );
    in
    parsed;

  envFile = "/mnt/lima-cidata/lima.env";
  env = parseEnv (builtins.readFile envFile);
in
{
  deepMerge = deepMerge;
  parseEnv = parseEnv;
  env = env;
}
