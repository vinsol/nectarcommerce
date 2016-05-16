import React from "react";

export default class DismissableAlert extends React.Component {

  render() {
    return (<div className="alert alert-danger">
            <a href="#" class="close" title="close" onClick={this.props.dismiss}>×</a>
              <span>{this.props.message}</span>
            </div>);
  }
}
