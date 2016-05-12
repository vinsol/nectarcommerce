import React from "react";


class Product extends React.Component {
  render() {
    return (
      <div className="panel-group col-lg-3">
        <div className="panel panel-default">
          <div className="panel-body">{this.props.product.name}</div>
          <div className="panel-body">
            <a href={this.props.product.link}>
              <img src={this.props.product.thumbnail} title={this.props.product.name}></img>
            </a>
          </div>
          <div className="panel-footer">
            <span>{this.props.product.cost_price}</span>
          </div>
        </div>
      </div>
    );
  }
}

export default Product;
