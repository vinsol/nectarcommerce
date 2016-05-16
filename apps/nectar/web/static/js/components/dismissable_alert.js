import React from "react";

export default class DismissableAlert extends React.Component {

  constructor() {
    super();
    this.dismiss = this.dismiss.bind(this);
  }

  dismiss() {
    this.props.clear(this.props.index);
  }

  render() {
    return (<div className="alert alert-danger">
            <a href="#" class="close" title="close" onClick={this.dismiss}>×</a>
              <span>{this.props.message}</span>
            </div>);
  }
}
