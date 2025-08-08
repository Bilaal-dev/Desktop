import React from "react";
import ReactDOM from "react-dom/client"; // Notice: 'react-dom/client'

// CSS
import "./index.css";
//setup vars
const books = [
  {
    author: "Amelia Hepworth",
    title: "I Love You to the Moon and Back",
    img: "https://images-na.ssl-images-amazon.com/images/I/81mpSoJzv4L._AC_UL300_SR300,200_.jpg",
  },
  {
    author: "Haley Pham",
    title: "Just Friends: A Novel",
    img: "https://images-na.ssl-images-amazon.com/images/I/5139Ak3KfaL._AC_UL300_SR300,200_.jpg",
  },
  {
    author: "Johnny Joey Jones",
    title: "Behind the Badge",
    img: "https://images-na.ssl-images-amazon.com/images/I/71aOvZBV1cL._AC_UL300_SR300,200_.jpg",
  },
];

// JSX Rules
// return a single element
// div/ section / article or Fragment
// use camelCase for html attribute
// className instead of class
// close every element
// Formatting

//Nested Components, React Tools

// function Greeting() {
//   return (
//     <div>
//       <h1>Hi Guys!</h1>
//     <p>This is Bilaal and this is my first component</p>
//     <Message />
//     <Address />
//     </div>
//   );
// }

// const Message = () =>{
//   return<p>Glad to meet Y'all</p>
// }
// const Address = () => <p>I hope y'all enjoy this Course.</p>;

// const root = ReactDOM.createRoot(document.getElementById('root'));
// root.render(<Greeting />);

// const Hi = ()=>{
//   return React.createElement('h1', {}, 'Hello');
// };

// 👇 This is the new way to render in React 18+
function BookList() {
  return (
    <section className="booklist">
      {books.map((book) => {
        return <Book book={book}></Book>;
      })}
    </section>
  );
}

//another component using arrow function.
const Book = (props) => {
  const { img, title, author } = props.book;
  return (
    <article className="book">
      <img src={img} alt="" />
      <h1>{title}</h1>
      <h4
        style={{ color: "#617d98", fontSize: "0.75rem", marginTop: "0.25rem" }}
      >
        {author}
      </h4>
    </article>
  );
};

const book = ReactDOM.createRoot(document.getElementById("root"));
book.render(<BookList />);
