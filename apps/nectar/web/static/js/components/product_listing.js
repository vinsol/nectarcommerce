import React from "react";
import Product from "./product";
import {connect} from 'react-redux';

class ProductListing extends React.Component {
  render() {
    const products = this.props.products.map(
      (product, idx) => (<Product product={product} key={idx}/>)
    );

    return(
      <div className="row">
        <div className="col-md-12">
          {products}
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => ( state.products );

export default connect(mapStateToProps)(ProductListing);
