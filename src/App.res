let s = React.string
/*
 * #09 - Result type ou Result.t
 * 1. O que é?
 * 2. Quando e como utilizar?
 * 3. Utilizando com Pattern Matching e Belt.Result.t
 * 4. Exemplo de uso com fetch + rescript-jzon
 */

/* let validateAge = age => { */
/* if age > 18 { */
/* Ok(`Maior de 18`) */
/* } else { */
/* Error(`Menor de 18`) */
/* } */
/* } */

/* switch result { */
/* | Ok(message) => Js.log(message) */
/* | Error(_) => Js.Console.error(`Mensagem de erro...`) */
/* } */

/* "id": 1, */
/* "name": "Leanne Graham", */
/* "username": "Bret", */
/* "email": "Sincere@april.biz", */

type user = {
  id: int,
  name: string,
  username: string,
  email: string,
}

let codec = Jzon.object4(
  ({id, name, username, email}) => (id, name, username, email),
  ((id, name, username, email)) => Ok({id: id, name: name, username: username, email: email}),
  Jzon.field("id", Jzon.int),
  Jzon.field("name", Jzon.string),
  Jzon.field("username", Jzon.string),
  Jzon.field("email", Jzon.string),
)

let apiUrl = `https://jsonplaceholder.typicode.com/users`

let getUserById = (~id) => {
  open Webapi

  Fetch.fetch(`${apiUrl}/${id->Js.Int.toString}`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(json => json->Jzon.decodeWith(codec))
}

type state = Loading | Error | Data(user)

@react.component
let make = () => {
  let (state, setState) = React.useState(_ => Loading)

  React.useEffect0(() => {
    getUserById(~id=1)
    ->Promise.thenResolve(result =>
      result->Belt.Result.map(data => Data(data))->Belt.Result.getWithDefault(Error)
    )
    ->Promise.thenResolve(state => setState(_ => state))
    ->ignore

    None
  })

  <div className="main-container">
    {switch state {
    | Loading => <h2> {`Loading...`->s} </h2>
    | Error => <h2> {`Algo deu errado :(`->s} </h2>
    | Data(user) =>
      <h2> {`Name: ${user.name} Email: ${user.email} Username: ${user.username}`->s} </h2>
    }}
  </div>
}
